option(QE_ENABLE_VENDOR_DEPS "enable fallback on vendored deps when none is found via find_package()" ON)

###########################################################
# QE::LAPACK
###########################################################
find_package(LAPACK QUIET)
if(LAPACK_FOUND)
    add_library(qe_lapack INTERFACE)
    add_library(QE::LAPACK ALIAS qe_lapack)
    target_link_libraries(qe_lapack INTERFACE ${LAPACK_LIBRARIES})
else(LAPACK_FOUND)
    if(TARGET QE::LAPACK)
        message(STATUS "Using inherited QE::LAPACK target")
    else(TARGET QE::LAPACK)
        if(QE_ENABLE_VENDOR_DEPS)
            message(STATUS "Installing QE::LAPACK via submodule")
            execute_process(COMMAND git submodule update --init -- external/lapack
                            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
            add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/external/lapack EXCLUDE_FROM_ALL)
            add_library(QE::LAPACK ALIAS lapack)
        else(QE_ENABLE_VENDOR_DEPS)
            # No dep has been found via find_package,
            # call it again with REQUIRED to make it fail
            # explicitly (hoping in some helpful message)
            find_package(LAPACK REQUIRED)
        endif(QE_ENABLE_VENDOR_DEPS)
    endif(TARGET QE::LAPACK)
endif(LAPACK_FOUND)

###########################################################
# QE::FOX
###########################################################
find_package(FoX QUIET)
if(FoX_FOUND)
    add_library(qe_fox INTERFACE)
    add_library(QE::FOX ALIAS qe_fox)
    target_link_libraries(qe_fox INTERFACE ${FoX_LIBRARIES})
else(FoX_FOUND)
    if(TARGET QE::FOX)
        message(STATUS "Using inherited QE::FOX target")
    else(TARGET QE::FOX)
        if(QE_ENABLE_VENDOR_DEPS)
            message(STATUS "Installing QE::FOX via submodule")
            set(fox_targets
                FoX_fsys
                FoX_utils
                FoX_common
                FoX_dom
                FoX_sax
                FoX_wxml)
            set(FoX_ENABLE_EXAMPLES OFF CACHE BOOL "" FORCE)
            execute_process(COMMAND git submodule update --init -- external/fox
                            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
            add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/external/fox EXCLUDE_FROM_ALL)
            add_library(qe_fox INTERFACE)
            add_library(QE::FOX ALIAS qe_fox)
            target_link_libraries(qe_fox INTERFACE ${fox_targets})
            target_include_directories(qe_fox
                INTERFACE
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/external/fox/modules>)
                    # TODO fix FoX module dir
                    # INTERFACE
                    #     $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/qe>)
            foreach(tgt IN LISTS fox_targets)
                qe_install_target(${tgt})
            endforeach()
        else(QE_ENABLE_VENDOR_DEPS)
            # No dep has been found via find_package,
            # call it again with REQUIRED to make it fail
            # explicitly (hoping in some helpful message)
            find_package(FoX REQUIRED)
        endif(QE_ENABLE_VENDOR_DEPS)
    endif(TARGET QE::FOX)
endif(FoX_FOUND)