# Using Vivado projects with version control system

HowTo guide for managing vivado projects with tcl script project creation. Working with Version 2018.2.2 (Problems if Vivado versions of creation and usage are different)

## How to create a script from an existing project

1. Make sure, that all the (versioned) source files are added as a reference to your project (reference to your local git repository -- do not copy the files into your project)

2. Use a file structure according to the Vivado best practice guide

3. File->Project->Write Tcl...

4. Specify output file (disable all options)

5. Open created script with a text editor

6. Go to the "create_project" command and replace "./${_xil_proj_name_}" with "$orig_proj_dir"

7. Commit the script

## How to build a project with a (generated) tcl script

1. Check out the repository containing the project you want to create

2. Open tcl script used to build the project with a text editor

3. Got to variable "origin_dir" and set the absolute path to the directory where the tcl script is located (e.g. set origin_dir "C:/Users/Rupert Schorn/Documents/TU_Wien/Sem11/Labor SoC Design/GIT/FailsafeECU/Design/Hardware/BusMonitor/script")

4. Got to variable "orig_proj_dir" and set the absolute path to the directory where you want to create your project (e.g. set orig_proj_dir "C:/Vivado/BusMonitor")

5. Open Vivado

6. Tools->Run Tcl Script...

7. Select the tcl script to build the project

8. Check the Tcl Console for errors and warnings and check if the sources are available within the project tree