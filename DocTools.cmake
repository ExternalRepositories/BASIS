##############################################################################
# @file  DocTools.cmake
# @brief Tools related to gnerating or adding software documentation.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_DOCTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_DOCTOOLS_INCLUDED TRUE)
endif ()


# ============================================================================
# used programs
# ============================================================================

# Doxygen - used by basis_add_doc()
find_package (Doxygen)

## @brief Command svn2cl which is used to generate a ChangeLog from the Subversion log.
find_program (
  SVN2CL_EXECUTABLE
    NAMES svn2cl svn2cl.sh
    DOC   "The command line tool svn2cl."
)
mark_as_advanced (SVN2CL_EXECUTABLE)

# ============================================================================
# settings
# ============================================================================

## @addtogroup CMakeUtilities
#  @{


## @brief Default Doxygen configuration.
set (BASIS_DOXYGEN_DOXYFILE "${CMAKE_CURRENT_LIST_DIR}/Doxyfile.in")


## @}
# end of Doxygen group


# ============================================================================
# adding / generating documentation
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add documentation target.
#
# This function is especially used to add a custom target to the "doc" target
# which is used to generate documentation from input files such as in
# particular source code files. Other documentation files such as HTML, Word,
# or PDF documents can be added as well using this function. A component
# as part of which this documentation shall be installed can be specified.
#
# @param [in] TARGET_NAME Name of the documentation target or file.
# @param [in] ARGN        List of arguments. The valid arguments are:
# @par
# <table border="0">
#   <tr>
#     @tp @b COMPONENT component @endtp
#     <td>Name of the component this documentation belongs to.
#         Defaults to @c BASIS_LIBRARY_COMPONENT for documentation generated
#         from in-source comments and @c BASIS_RUNTIME_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATOR generator @endtp
#     <td>Documentation generator, where the case of the generator name is
#         ignored, i.e., @c Doxygen, @c DOXYGEN, @c doxYgen are all valid
#         arguments which select the @c Doxygen generator. The parameters for the
#         different supported generators are documented below.
#         The default generator is @c None. The @c None generator simply installs
#         the document with the filename @c TARGET_NAME and has no own options.</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory prefix. Defaults to @c INSTALL_DOC_DIR or
#         <tt>INSTALL_DOC_DIR/&lt;target&gt;</tt> in case of the Doxygen generator,
#         where <tt>&lt;target&gt;</tt> is the @c TARGET_NAME in lowercase only.</td>
#   </tr>
# </table>
#
# @par Generator: None
# @n
# The documentation files are installed in/as <tt>INSTALL_DOC_DIR/TARGET_NAME</tt>
# as part of the component specified by the @c COMPONENT option.
# @n@n
# <table border="0">
#   <tr>
#     @tp @b OUTPUT_NAME filename @endtp
#     <td>Name of installed documentationf file. Default: @p TARGET_NAME.</td>
#   </tr>
# </table>
# @n
# Example:
# @code
# basis_add_doc ("User Manual.pdf" OUTPUT_NAME "BASIS User Manual.pdf")
# basis_add_doc (DeveloperManual.docx COMPONENT dev)
# basis_add_doc (SourceManual.html    COMPONENT src)
# @endcode
#
# @par Generator: Doxygen
# @n
# Uses the <a href="http://www.stack.nl/~dimitri/doxygen/index.html">Doxygen</a> tool
# to generate the documentation from in-source code comments.
# @n@n
# <table border="0">
#   <tr>
#     @tp @b DOXYFILE file @endtp
#     <td>Name of the template Doxyfile.</td>
#   </tr>
#   <tr>
#     @tp @b PROJECT_NAME name @endtp
#     <td>Value for Doxygen's @c PROJECT_NAME tag which is used to
#         specify the project name.@n
#         Default: @c PROJECT_NAME.</td>
#   </tr>
#   <tr>
#     @tp @b PROJECT_NUMBER version @endtp
#     <td>Value for Doxygen's @c PROJECT_NUMBER tag which is used
#         to specify the project version number.@n
#         Default: @c PROJECT_VERSION_AND_REVISION.</td>
#   </tr>
#   <tr>
#     @tp @b INPUT path1 [path2 ...] @endtp
#     <td>Value for Doxygen's @c INPUT tag which is used to specify input
#         directories/files. Any given input path is added to the default
#         input paths.@n
#         Default: @c PROJECT_CODE_DIR, @c BINARY_CODE_DIR,
#                  @c PROJECT_INCLUDE_DIR, @c BINARY_INCLUDE_DIR.</td>
#   </tr>
#   <tr>
#     @tp @b INPUT_FILTER filter @endtp
#     <td>
#       Value for Doxygen's @c INPUT_FILTER tag which can be used to
#       specify a default filter for all input files. If additional
#       @b FILTER_PATTERNS are given, this filter is appended to the list
#       of filter patterns and applied for the pattern '*', i.e., used to
#       process any input file which has not yet been processed by another
#       input filter.@n
#       Default: @c doxyfilter of BASIS.
#     </td>
#   <tr>
#     @tp @b FILTER_PATTERNS pattern1 [pattern2...] @endtp
#     <td>Value for Doxygen's @c FILTER_PATTERNS tag which can be used to
#         specify filters on a per file pattern basis.@n
#         Default: None.</td>
#   </tr>
#   <tr>
#     @tp @b INCLUDE_PATH path1 [path2...] @endtp
#     <td>Doxygen's @c INCLUDE_PATH tag can be used to specify one or more
#         directories that contain include files that are not input files
#         but should be processed by the preprocessor. Any given directories
#         are appended to the default include path considered.
#         Default: Directories added by basis_include_directories().</td>
#   </tr>
#   <tr>
#     @tp @b EXCLUDE_PATTERNS pattern1 [pattern2 ...] @endtp
#     <td>Additional patterns used for Doxygen's @c EXCLUDE_PATTERNS tag
#         which can be used to specify files and/or directories that
#         should be excluded from the INPUT source files.@n
#         Default: No exclude patterns.</td>
#   </tr>
#   <tr>
#     @tp @b OUTPUT_DIRECTORY dir @endtp
#     <td>Value for Doxygen's @c OUTPUT_DIRECTORY tag which can be used to
#         specify the output directory. The output files are written to
#         subdirectories named "html", "latex", "rtf", and "man".@n
#         Default: <tt>CMAKE_CURRENT_BINARY_DIR/TARGET_NAME</tt>.</td>
#   </tr>
#   <tr>
#     @tp @b COLS_IN_ALPHA_INDEX n @endtp
#     <td>Number of columns in alphabetical index if @p GENERATE_HTML is @c YES.
#         Default: 3.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_HTML @endtp
#     <td>If given, Doxygen's @c GENERATE_HTML tag is set to YES, otherwise NO.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_LATEX @endtp
#     <td>If given, Doxygen's @c GENERATE_LATEX tag is set to YES, otherwise NO.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_RTF @endtp
#     <td>If given, Doxygen's @c GENERATE_RTF tag is set to YES, otherwise NO.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_MAN @endtp
#     <td>If given, Doxygen's @c GENERATE_MAN tag is set to YES, otherwise NO.</td>
#   </tr>
# </table>
# @n
# See <a href="http://www.stack.nl/~dimitri/doxygen/config.html">here</a> for a
# documentation of the Doxygen tags. If none of the <tt>GENERATE_&lt;*&gt;</tt>
# options is given, @c GENERATE_HTML is set to @c YES.
# @n@n
# Example:
# @code
# basis_add_doc (
#   api
#   GENERATOR Doxygen
#     DOXYFILE        "Doxyfile.in"
#     PROJECT_NAME    "${PROJECT_NAME}"
#     PROJECT_VERSION "${PROJECT_VERSION}"
#   COMPONENT dev
# )
# @endcode
#
# @returns Adds a custom target @p TARGET_NAME for the generation of the
#          documentation or configures the given file in case of the @c None
#          generator.
#
# @ingroup CMakeAPI
function (basis_add_doc TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "GENERATOR;COMPONENT;DESTINATION" "" ${ARGN})

  # default generator
  if (NOT ARGN_GENERATOR)
    set (ARGN_GENERATOR "NONE")
  else ()
    # generator name is case insensitive
    string (TOUPPER "${ARGN_GENERATOR}" ARGN_GENERATOR)
  endif ()

  # check target name
  if (NOT ARGN_GENERATOR MATCHES "NONE")
    basis_check_target_name ("${TARGET_NAME}")
    basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  endif ()

  # lower target name is used, for example, for default DESTINATION
  string (TOLOWER "${TARGET_NAME}" TARGET_NAME_LOWER)

  # default destination
  if (NOT ARGN_DESTINATION)
    if (ARGN_GENERATOR MATCHES "DOXYGEN")
      if (NOT INSTALL_APIDOC_DIR)
        set (
          INSTALL_APIDOC_DIR "${INSTALL_DOC_DIR}/${TARGET_NAME_LOWER}"
          CACHE PATH
            "Installation directory of API documentation."
        )
        mark_as_advanced (INSTALL_APIDOC_DIR)
      endif ()
      set (ARGN_DESTINATION "${INSTALL_APIDOC_DIR}")
    else ()
      set (ARGN_DESTINATION "${INSTALL_DOC_DIR}")
    endif ()
  endif ()

  # default component
  if (ARGN_GENERATOR MATCHES "DOXYGEN")
    if (NOT ARGN_COMPONENT)
      set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
    endif ()
  else ()
    if (NOT ARGN_COMPONENT)
      set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  # --------------------------------------------------------------------------
  # generator: NONE
  # --------------------------------------------------------------------------

  if (ARGN_GENERATOR MATCHES "NONE")

    CMAKE_PARSE_ARGUMENTS (DOC "" "OUTPUT_NAME" "" ${ARGN_UNPARSED_ARGUMENTS})

    if (NOT DOC_OUTPUT_NAME)
      set (DOC_OUTPUT_NAME "${TARGET_NAME}")
    endif ()

    basis_get_relative_path (
      DOC_PATH
        "${CMAKE_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/${DOC_OUTPUT_NAME}"
    )

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${DOC_PATH}...")
    endif ()

    # install documentation directory
    if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}")
      install (
        DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}/"
        DESTINATION "${ARGN_DESTINATION}/${DOC_OUTPUT_NAME}"
        COMPONENT   "${ARGN_COMPONENT}"
        PATTERN     ".svn" EXCLUDE
        PATTERN     ".git" EXCLUDE
        PATTERN     "*~"   EXCLUDE
      )
    # install documentation file
    else ()
      install (
        FILES       "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}"
        DESTINATION "${ARGN_DESTINATION}"
        COMPONENT   "${ARGN_COMPONENT}"
        RENAME      "${DOC_OUTPUT_NAME}"
      )
    endif ()

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${DOC_PATH}... - done")
    endif ()

  # --------------------------------------------------------------------------
  # generator: DOXYGEN
  # --------------------------------------------------------------------------

  elseif (ARGN_GENERATOR MATCHES "DOXYGEN")

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}...")
    endif ()

    # Doxygen found ?
    if (BUILD_DOCUMENTATION)
      set (ERRMSGTYP "")
      set (ERRMSG    "failed")
    else ()
      set (ERRMSGTYP "STATUS")
      set (ERRMSG    "skipped")
    endif ()

    if (NOT DOXYGEN_EXECUTABLE)
      message (${ERRMSGTYP} "Doxygen not found. Generation of ${TARGET_UID} documentation disabled.")
      if (BASIS_VERBOSE)
        message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      endif ()
      return ()
    endif ()

    # parse arguments
    CMAKE_PARSE_ARGUMENTS (
      DOXYGEN
        "GENERATE_HTML;GENERATE_LATEX;GENERATE_RTF;GENERATE_MAN"
        "DOXYFILE;TAGFILE;PROJECT_NAME;PROJECT_NUMBER;OUTPUT_DIRECTORY;COLS_IN_ALPHA_INDEX"
        "INPUT;INPUT_FILTER;FILTER_PATTERNS;EXCLUDE_PATTERNS;INCLUDE_PATH"
        ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (NOT DOXYGEN_DOXYFILE)
      set (DOXYGEN_DOXYFILE "${BASIS_DOXYGEN_DOXYFILE}")
    endif ()
    if (NOT EXISTS "${DOXYGEN_DOXYFILE}")
      message (FATAL_ERROR "Missing option DOXYGEN_FILE or Doxyfile ${DOXYGEN_DOXYFILE} does not exist.")
    endif ()

    if (NOT DOXYGEN_PROJECT_NAME)
      set (DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
    endif ()
    if (NOT DOXYGEN_PROJECT_NUMBER)
      set (DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION_AND_REVISION}")
    endif ()
    # standard input files
    list (APPEND DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/BasisProject.cmake")
    if (EXISTS "${PROJECT_CONFIG_DIR}/Depends.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_CONFIG_DIR}/Depends.cmake")
    endif ()
    if (EXISTS "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Directories.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Directories.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/BasisSettings.cmake")
      list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/BasisSettings.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/ProjectSettings.cmake")
      list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/ProjectSettings.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/Settings.cmake")
      list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/Settings.cmake")
    elseif (EXISTS "${PROJECT_CONFIG_DIR}/Settings.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_CONFIG_DIR}/Settings.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
      list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
      list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
    endif ()
    if (EXISTS "${PROJECT_CONFIG_DIR}/ConfigSettings.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_CONFIG_DIR}/ConfigSettings.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/${PROJECT_NAME}Config.cmake")
      list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/${PROJECT_NAME}Config.cmake")
    endif ()
    if (EXISTS "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")
    endif ()
    if (EXISTS "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Use.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Use.cmake")
    endif ()
    if (EXISTS "${PROJECT_SOURCE_DIR}/CTestConfig.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/CTestConfig.cmake")
    endif ()
    if (EXISTS "${PROJECT_BINARY_DIR}/CTestCustom.cmake")
      list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/CTestCustom.cmake")
    endif ()
    # input directories
    if (NOT BASIS_AUTO_PREFIX_INCLUDES AND EXISTS "${PROJECT_INCLUDE_DIR}")
      list (APPEND DOXYGEN_INPUT "${PROJECT_INCLUDE_DIR}")
    endif ()
    if (EXISTS "${BINARY_INCLUDE_DIR}")
      list (APPEND DOXYGEN_INPUT "${BINARY_INCLUDE_DIR}")
    endif ()
    if (EXISTS "${BINARY_CODE_DIR}")
      list (APPEND DOXYGEN_INPUT "${BINARY_CODE_DIR}")
    endif ()
    if (EXISTS "${PROJECT_CODE_DIR}")
      list (APPEND DOXYGEN_INPUT "${PROJECT_CODE_DIR}")
    endif ()
    basis_get_relative_path (INCLUDE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_INCLUDE_DIR}")
    basis_get_relative_path (CODE_DIR    "${PROJECT_SOURCE_DIR}" "${PROJECT_CODE_DIR}")
    foreach (M IN LISTS PROJECT_MODULES_ENABLED)
      if (EXISTS "${PROJECT_MODULES_DIR}/${M}/${CODE_DIR}")
        list (APPEND DOXYGEN_INPUT "${PROJECT_MODULES_DIR}/${M}/${CODE_DIR}")
      endif ()
      if (EXISTS "${PROJECT_MODULES_DIR}/${M}/${INCLUDE_DIR}")
        list (APPEND DOXYGEN_INPUT "${BINARY_MODULES_DIR}/${M}/${INCLUDE_DIR}")
      endif ()
    endforeach ()
    # add .dox files as input
    file (GLOB_RECURSE DOX_FILES "${PROJECT_DOC_DIR}/*.dox")
    list (SORT DOX_FILES) # alphabetic order
    list (APPEND DOXYGEN_INPUT ${DOX_FILES})
    # add .dox files of BASIS modules
    if (PROJECT_NAME MATCHES "^BASIS$")
      set (FilesystemHierarchyStandardPageRef "@ref FilesystemHierarchyStandard")
      set (BuildOfScriptTargetsPageRef        "@ref BuildOfScriptTargets")
    else ()
      set (FilesystemHierarchyStandardPageRef "Filesystem Hierarchy Standard")
      set (BuildOfScriptTargetsPageRef        "build of script targets")
    endif ()
    configure_file(
      "${BASIS_MODULE_PATH}/Modules.dox.in"
      "${CMAKE_CURRENT_BINARY_DIR}/BasisModules.dox" @ONLY)
    list (APPEND DOXYGEN_INPUT "${CMAKE_CURRENT_BINARY_DIR}/BasisModules.dox")
    # add .dox files of used BASIS utilities
    list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox")
    list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/CxxUtilities.dox")
    foreach (L IN ITEMS Cxx Java Python Perl Bash Matlab)
      string (TOUPPER "${L}" U)
      if (U MATCHES "CXX")
        if (BASIS_UTILITIES_ENABLED MATCHES "CXX")
          set (PROJECT_USES_CXX_UTILITIES TRUE)
        else ()
          set (PROJECT_USES_CXX_UTILITIES FALSE)
        endif ()
      else ()
        basis_get_project_property (USES_${U}_UTILITIES PROPERTY PROJECT_USES_${U}_UTILITIES)
      endif ()
      if (USES_${U}_UTILITIES)
        list (FIND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox" IDX)
        if (IDX EQUAL -1)
          list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox")
        endif ()
        list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/${L}Utilities.dox")
      endif ()
    endforeach ()
    # include path
    basis_get_project_property (INCLUDE_DIRS PROPERTY PROJECT_INCLUDE_DIRS)
    foreach (D IN LISTS INCLUDE_DIRS)
      list (FIND DOXYGEN_INPUT "${D}" IDX)
      if (IDX EQUAL -1)
        list (APPEND DOXYGEN_INCLUDE_PATH "${D}")
      endif ()
    endforeach ()
    basis_list_to_delimited_string (
      DOXYGEN_INCLUDE_PATH "\"\nINCLUDE_PATH          += \"" ${DOXYGEN_INCLUDE_PATH}
    )
    set (DOXYGEN_INCLUDE_PATH "\"${DOXYGEN_INCLUDE_PATH}\"")
    # make string from DOXYGEN_INPUT - after include path was set
    basis_list_to_delimited_string (
      DOXYGEN_INPUT "\"\nINPUT                 += \"" ${DOXYGEN_INPUT}
    )
    set (DOXYGEN_INPUT "\"${DOXYGEN_INPUT}\"")
    # input filters
    if (NOT DOXYGEN_INPUT_FILTER)
      basis_get_target_uid (DOXYFILTER "${BASIS_NAMESPACE_LOWER}.basis.doxyfilter")
      if (TARGET "${DOXYFILTER}")
        basis_get_target_location (DOXYGEN_INPUT_FILTER "${DOXYFILTER}" ABSOLUTE)
      endif ()
    else ()
      set (DOXYFILTER)
    endif ()
    if (DOXYGEN_INPUT_FILTER)
      list (APPEND DOXYGEN_FILTER_PATTERNS "*=${DOXYGEN_INPUT_FILTER}")
    endif ()
    basis_list_to_delimited_string (
      DOXYGEN_FILTER_PATTERNS "\"\nFILTER_PATTERNS       += \"" ${DOXYGEN_FILTER_PATTERNS}
    )
    set (DOXYGEN_FILTER_PATTERNS "\"${DOXYGEN_FILTER_PATTERNS}\"")
    # exclude patterns
    list (APPEND DOXYGEN_EXCLUDE_PATTERNS "cmake_install.cmake")
    list (APPEND DOXYGEN_EXCLUDE_PATTERNS "CTestTestfile.cmake")
    basis_list_to_delimited_string (
      DOXYGEN_EXCLUDE_PATTERNS "\"\nEXCLUDE_PATTERNS      += \"" ${DOXYGEN_EXCLUDE_PATTERNS}
    )
    set (DOXYGEN_EXCLUDE_PATTERNS "\"${DOXYGEN_EXCLUDE_PATTERNS}\"")
    # outputs
    if (NOT DOXYGEN_OUTPUT_DIRECTORY)
      set (DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME_LOWER}")
    endif ()
    if (DOXYGEN_TAGFILE MATCHES "^(None|NONE|none)$")
      set (DOXYGEN_TAGFILE)
    else ()
      set (DOXYGEN_TAGFILE "${DOXYGEN_OUTPUT_DIRECTORY}/doxygen.tags")
    endif ()
    set (NUMBER_OF_OUTPUTS 0)
    foreach (FMT HTML LATEX RTF MAN)
      set (VAR DOXYGEN_GENERATE_${FMT})
      if (${VAR})
        set (${VAR} "YES")
        math (EXPR NUMBER_OF_OUTPUTS "${NUMBER_OF_OUTPUTS} + 1")
      else ()
        set (${VAR} "NO")
      endif ()
    endforeach ()
    if (NUMBER_OF_OUTPUTS EQUAL 0)
      set (DOXYGEN_GENERATE_HTML "YES")
      set (NUMBER_OF_OUTPUTS 1)
    endif ()
    # other settings
    if (NOT DOXYGEN_COLS_IN_ALPHA_INDEX OR DOXYGEN_COLS_IN_ALPHA_INDEX MATCHES "[^0-9]")
      set (DOXYGEN_COLS_IN_ALPHA_INDEX 3)
    endif ()
    # HTML style
    set (DOXYGEN_HTML_STYLESHEET "${BASIS_MODULE_PATH}/doxygen_sbia.css")
    set (DOXYGEN_HTML_HEADER     "${BASIS_MODULE_PATH}/doxygen_header.html")
    set (DOXYGEN_HTML_FOOTER     "${BASIS_MODULE_PATH}/doxygen_footer.html")

    # set output paths relative to DOXYGEN_OUTPUT_DIRECTORY
    set (DOXYGEN_HTML_OUTPUT  "html")
    set (DOXYGEN_LATEX_OUTPUT "latex")
    set (DOXYGEN_RTF_OUTPUT   "rtf")
    set (DOXYGEN_MAN_OUTPUT   "man")

    # click & jump in emacs and Visual Studio
    if (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
      set (DOXYGEN_WARN_FORMAT "\"$file($line) : $text \"")
    else ()
      set (DOXYGEN_WARN_FORMAT "\"$file:$line: $text \"")
    endif ()

    # configure Doxyfile
    set (DOXYFILE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME_LOWER}.doxy")
    configure_file ("${DOXYGEN_DOXYFILE}" "${DOXYFILE}" @ONLY)

    # add target
    set (LOGOS)
    if (DOXYGEN_HTML_OUTPUT)
      set (LOGOS "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_sbia.png"
                 "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_penn.png")
      add_custom_command (
        OUTPUT   ${LOGOS}
        COMMAND "${CMAKE_COMMAND}" -E copy
                  "${BASIS_MODULE_PATH}/logo_sbia.png"
                  "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_sbia.png"
        COMMAND "${CMAKE_COMMAND}" -E copy
                  "${BASIS_MODULE_PATH}/logo_penn.gif"
                  "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_penn.gif"
        COMMENT "Copying logos to ${DOXYGEN_OUTPUT_DIRECTORY}/html/..."
      )
    endif ()

    add_custom_target (
      ${TARGET_UID} "${DOXYGEN_EXECUTABLE}" "${DOXYFILE}"
      DEPENDS ${LOGOS}
      WORKING_DIRECTORY "${BASIS_MODULE_DIR}"
      COMMENT "Building documentation ${TARGET_UID}..."
    )

    # cleanup on "make clean"
    set_property (
      DIRECTORY
      APPEND PROPERTY
        ADDITIONAL_MAKE_CLEAN_FILES
          "${DOXYGEN_OUTPUT_DIRECTORY}/html"
          "${DOXYGEN_OUTPUT_DIRECTORY}/latex"
          "${DOXYGEN_OUTPUT_DIRECTORY}/rtf"
          "${DOXYGEN_OUTPUT_DIRECTORY}/man"
    )

    # clean up / install tags file
    if (DOXYGEN_TAGFILE)
      set_property (
        DIRECTORY
        APPEND PROPERTY
          ADDITIONAL_MAKE_CLEAN_FILES
            "${DOXYGEN_TAGFILE}"
      )
    endif ()

    # add target as dependency to doc target
    if (NOT TARGET doc)
      if (BUILD_DOCUMENTATION)
        add_custom_target (doc ALL)
      else ()
        add_custom_target (doc)
      endif ()
    endif ()

    add_dependencies (doc ${TARGET_UID})
    if (TARGET headers)
      add_dependencies (${TARGET_UID} headers)
    endif ()
    if (TARGET scripts)
      add_dependencies (${TARGET_UID} scripts)
    endif ()
    if (TARGET "${DOXYFILTER}")
      add_dependencies (${TARGET_UID} ${DOXYFILTER})
    endif ()

    # install documentation
    install (
      CODE
        "
        set (INSTALL_PREFIX \"${ARGN_DESTINATION}\")
        if (NOT IS_ABSOLUTE \"\${INSTALL_PREFIX}\")
          set (INSTALL_PREFIX \"${INSTALL_PREFIX}/\${INSTALL_PREFIX}\")
        endif ()

        macro (install_doxydoc DIR)
          file (
            GLOB_RECURSE
              FILES
            RELATIVE \"${DOXYGEN_OUTPUT_DIRECTORY}\"
              \"${DOXYGEN_OUTPUT_DIRECTORY}/\${DIR}/*\"
          )
          foreach (F IN LISTS FILES)
            execute_process (
              COMMAND \"${CMAKE_COMMAND}\" -E compare_files
                  \"${DOXYGEN_OUTPUT_DIRECTORY}/\${F}\"
                  \"\${INSTALL_PREFIX}/\${F}\"
              RESULT_VARIABLE RC
              OUTPUT_QUIET
              ERROR_QUIET
            )
            if (RC EQUAL 0)
              message (STATUS \"Up-to-date: \${INSTALL_PREFIX}/\${F}\")
            else ()
              message (STATUS \"Installing: \${INSTALL_PREFIX}/\${F}\")
              execute_process (
                COMMAND \"${CMAKE_COMMAND}\" -E copy_if_different
                    \"${DOXYGEN_OUTPUT_DIRECTORY}/\${F}\"
                    \"\${INSTALL_PREFIX}/\${F}\"
                RESULT_VARIABLE RC
                OUTPUT_QUIET
                ERROR_QUIET
              )
              if (RC EQUAL 0)
                list (APPEND CMAKE_INSTALL_MANIFEST_FILES \"\${INSTALL_PREFIX}/\${F}\")
              else ()
                message (STATUS \"Failed to install \${INSTALL_PREFIX}/\${F}\")
              endif ()
            endif ()
          endforeach ()
        endmacro ()

        install_doxydoc (html)
        install_doxydoc (latex)
        install_doxydoc (rtf)
        install_doxydoc (man)

        if (EXISTS \"${DOXYGEN_TAGFILE}\")
          get_filename_component (DOXYGEN_TAGFILE_NAME \"${DOXYGEN_TAGFILE}\" NAME)
          execute_process (
            COMMAND \"${CMAKE_COMMAND}\" -E copy
              \"${DOXYGEN_TAGFILE}\"
              \"\${INSTALL_PREFIX}/\${DOXYGEN_TAGFILE_NAME}\"
          )
          list (APPEND CMAKE_INSTALL_MANIFEST_FILES \"\${INSTALL_PREFIX}/\${DOXYGEN_TAGFILE_NAME}\")
        endif ()
        "
    )

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}... - done")
    endif ()

  # --------------------------------------------------------------------------
  # generator: unknown
  # --------------------------------------------------------------------------

  else ()
    message (FATAL_ERROR "Unknown documentation generator: ${ARGN_GENERATOR}.")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add target for generation of ChangeLog file.
#
# The ChangeLog is either generated from the Subversion or Git log depending
# on which revision control system is used by the project. Moreover, the
# project's source directory must be either a Subversion working copy or
# the root of a Git repository, respectively. In case of Subversion, if the
# command-line tool svn2cl(.sh) is installed, it is used to output a nicer
# formatted change log.
function (basis_add_changelog)
  basis_make_target_uid (TARGET_UID "changelog")

  option (BUILD_CHANGELOG "Request build and/or installation of the ChangeLog." OFF)
  set (CHANGELOG_FILE "${PROJECT_BINARY_DIR}/ChangeLog")

  if (BASIS_VERBOSE)
    message (STATUS "Adding ChangeLog...")
  endif ()

  if (BUILD_CHANGELOG)
    set (_ALL "ALL")
  else ()
    set (_ALL)
  endif ()

  set (DISABLE_BUILD_CHANGELOG FALSE)

  # --------------------------------------------------------------------------
  # generate ChangeLog from Subversion history
  if (EXISTS "${PROJECT_SOURCE_DIR}/.svn")
    find_package (Subversion QUIET)
    if (Subversion_FOUND)

      if (_ALL)
        message ("Generation of ChangeLog enabled as part of ALL."
                 " Be aware that the ChangeLog generation from the Subversion"
                 " commit history can take several minutes and may require the"
                 " input of your Subversion repository credentials during the"
                 " build. If you would like to build the ChangeLog separate"
                 " from the rest of the software package, disable the option"
                 " BUILD_CHANGELOG. You can then build the changelog target"
                 " separate from ALL.")
      endif ()

      # using svn2cl command
      if (SVN2CL_EXECUTABLE)
        add_custom_target (
          ${TARGET_UID} ${_ALL}
          COMMAND "${SVN2CL_EXECUTABLE}"
              "--output=${CHANGELOG_FILE}"
              "--linelen=79"
              "--reparagraph"
              "--group-by-day"
              "--include-actions"
              "--separate-daylogs"
              "${PROJECT_SOURCE_DIR}"
          COMMAND "${CMAKE_COMMAND}"
              "-DCHANGELOG_FILE:FILE=${CHANGELOG_FILE}" -DINPUTFORMAT=SVN2CL
              -P "${BASIS_MODULE_PATH}/PostprocessChangeLog.cmake"
          WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
          COMMENT "Generating ChangeLog from Subversion log (using svn2cl)..."
        )
      # otherwise, use svn log output directly
      else ()
        add_custom_target (
          ${TARGET_UID} ${_ALL}
          COMMAND "${CMAKE_COMMAND}"
              "-DCOMMAND=${Subversion_SVN_EXECUTABLE};log"
              "-DWORKING_DIRECTORY=${PROJECT_SOURCE_DIR}"
              "-DOUTPUT_FILE=${CHANGELOG_FILE}"
              -P "${BASIS_SCRIPT_EXECUTE_PROCESS}"
          COMMAND "${CMAKE_COMMAND}"
              "-DCHANGELOG_FILE:FILE=${CHANGELOG_FILE}" -DINPUTFORMAT=SVN
              -P "${BASIS_MODULE_PATH}/PostprocessChangeLog.cmake"
          COMMENT "Generating ChangeLog from Subversion log..."
          VERBATIM
        )
      endif ()

    else ()
      message (STATUS "Project is SVN working copy but Subversion executable was not found."
                      " Generation of ChangeLog disabled.")
      set (DISABLE_BUILD_CHANGELOG TRUE)
    endif ()

  # --------------------------------------------------------------------------
  # generate ChangeLog from Git log
  elseif (EXISTS "${PROJECT_SOURCE_DIR}/.git")
    find_package (Git QUIET)
    if (GIT_FOUND)

      add_custom_target (
        ${TARGET_UID} ${_ALL}
        COMMAND "${CMAKE_COMMAND}"
            "-DCOMMAND=${GIT_EXECUTABLE};log;--date-order;--date=short;--pretty=format:%ad\ \ %an%n%n%w(79,8,10)* %s%n%n%b%n"
            "-DWORKING_DIRECTORY=${PROJECT_SOURCE_DIR}"
            "-DOUTPUT_FILE=${CHANGELOG_FILE}"
            -P "${BASIS_SCRIPT_EXECUTE_PROCESS}"
        COMMAND "${CMAKE_COMMAND}"
            "-DCHANGELOG_FILE=${CHANGELOG_FILE}" -DINPUTFORMAT=GIT
            -P "${BASIS_MODULE_PATH}/PostprocessChangeLog.cmake"
        COMMENT "Generating ChangeLog from Git log..."
        VERBATIM
      )

    else ()
      message (STATUS "Project is Git repository but Git executable was not found."
                      " Generation of ChangeLog disabled.")
      set (DISABLE_BUILD_CHANGELOG TRUE)
    endif ()

  # --------------------------------------------------------------------------
  # neither SVN nor Git repository
  else ()
    message (STATUS "Project is neither SVN working copy nor Git repository."
                    " Generation of ChangeLog disabled.")
    set (DISABLE_BUILD_CHANGELOG TRUE)
  endif ()

  # --------------------------------------------------------------------------
  # disable changelog target
  if (DISABLE_BUILD_CHANGELOG)
    set (BUILD_CHANGELOG OFF CACHE INTERNAL "" FORCE)
    if (BASIS_VERBOSE)
      message (STATUS "Adding ChangeLog... - skipped")
    endif ()
    return ()
  endif ()

  # --------------------------------------------------------------------------
  # cleanup on "make clean"
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CHANGELOG_FILE}")

  # --------------------------------------------------------------------------
  # install ChangeLog
  install (
    FILES       "${CHANGELOG_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    COMPONENT   "${BASIS_RUNTIME_COMPONENT}"
    OPTIONAL
  )

  if (BASIS_VERBOSE)
    message (STATUS "Adding ChangeLog... - done")
  endif ()
endfunction ()
