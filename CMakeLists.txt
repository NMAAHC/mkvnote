cmake_minimum_required(VERSION 3.16)
project(mkvnote VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets Xml)

add_executable(mkvnote-gui WIN32
    main.cpp
    mainwindow.cpp
    mainwindow.h
)
target_link_libraries(mkvnote-gui PRIVATE
    Qt6::Core
    Qt6::Widgets
    Qt6::Xml
)
install(TARGETS mkvnote-gui DESTINATION bin)
install(PROGRAMS mkvnote DESTINATION bin)
