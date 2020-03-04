###########################################################
# QE build framework
# Please use the following functions in place of the
# corresponding CMake builtin
###########################################################

if(NOT TARGET QEGlobalCompileDefinitions)
    add_library(QEGlobalCompileDefinitions INTERFACE)
endif()

function(qe_add_global_compile_definitions DEF)
    if(TARGET QEGlobalCompileDefinitions)
        set_property(TARGET QEGlobalCompileDefinitions APPEND
                     PROPERTY INTERFACE_COMPILE_DEFINITIONS ${DEF} ${ARGN})
    endif()
endfunction(qe_add_global_compile_definitions)

function(qe_get_global_compile_definitions OUTVAR)
    if(TARGET QEGlobalCompileDefinitions)
        get_target_property(${OUTVAR} QEGlobalCompileDefinitions
            INTERFACE_COMPILE_DEFINITIONS)
    endif()
endfunction(qe_get_global_compile_definitions)

function(qe_get_fortran_cpp_flag OUTVAR)
    if(CMAKE_Fortran_COMPILER_ID STREQUAL "PGI")
        set(${OUTVAR} "-Mpreprocess" PARENT_SCOPE) # :'(
    else()
        # TODO actual flag check
        set(${OUTVAR} "-cpp" PARENT_SCOPE)
    endif()
endfunction(qe_get_fortran_cpp_flag)

function(qe_fix_fortran_modules LIB)
    set(targets ${LIB} ${ARGN})
    foreach(tgt IN LISTS targets)
        get_target_property(tgt_type ${tgt} TYPE)
        # All of the following target modifications make
        # sense on non-interfaces only
        if(NOT ${tgt_type} STREQUAL "INTERFACE_LIBRARY")
            get_target_property(tgt_module_dir ${tgt} Fortran_MODULE_DIRECTORY)
            # set module path to tgt_binary_dir/mod
            get_target_property(tgt_binary_dir ${tgt} BINARY_DIR)
            set_target_properties(${tgt}
                PROPERTIES
                Fortran_MODULE_DIRECTORY ${tgt_binary_dir}/mod/${LIB})
            # make module directory available for clients of LIB 
            target_include_directories(${tgt}
                PUBLIC
                $<BUILD_INTERFACE:${tgt_binary_dir}/mod/${LIB}>
                INTERFACE
                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/qe/${LIB}>)
        endif()
    endforeach()
endfunction(qe_fix_fortran_modules)

function(qe_git_submodule_update PATH)
    find_package(Git)
    # Old versions of git aren't able to run init+update
    # in one go (via 'git submodule update --init'), we need
    # to call one command for each operation:
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule init -- ${PATH}
                    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule update -- ${PATH}
                    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
endfunction(qe_git_submodule_update)

function(qe_add_executable EXE)
    add_executable(${EXE} ${ARGN})
    _qe_add_target(${EXE} ${ARGN})
endfunction(qe_add_executable)

function(qe_add_library LIB)
    add_library(${LIB} ${ARGN})
    _qe_add_target(${LIB} ${ARGN})
endfunction(qe_add_library)

function(_qe_add_target TGT)
    if(TARGET QEGlobalCompileDefinitions)
        target_link_libraries(${TGT} PUBLIC QEGlobalCompileDefinitions)
    endif()
    qe_fix_fortran_modules(${TGT})
    qe_get_fortran_cpp_flag(fortran_preprocess)
    target_compile_options(${TGT} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:${fortran_preprocess}>)
endfunction(_qe_add_target)

function(qe_install_targets TGT)
    set(targets ${TGT} ${ARGN})
    install(TARGETS ${targets}
        EXPORT qeTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} # Windows needs RUNTIME also for libraries
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qe/${TGT})
    # Retrieving non-whitelisted properties leads to an hard
    # error, let's skip the following section for interface
    # targets. See here for details:
    # https://gitlab.kitware.com/cmake/cmake/issues/17640
    foreach(tgt IN LISTS targets)
        get_target_property(tgt_type ${tgt} TYPE)
        if(NOT ${tgt_type} STREQUAL "INTERFACE_LIBRARY")
            # If the target generates Fortran modules, make sure
            # to install them as well to a proper location
            get_target_property(tgt_module_dir ${tgt} Fortran_MODULE_DIRECTORY)
            if(tgt_module_dir)
                install(DIRECTORY ${tgt_module_dir}/
                    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/qe/${TGT})
            endif()
        endif()        
    endforeach()
endfunction(qe_install_targets)

if(TARGET QEGlobalCompileDefinitions)
    qe_install_targets(QEGlobalCompileDefinitions)
endif()