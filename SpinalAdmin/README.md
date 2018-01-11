# SpinalAdmin

## Description

A modular web administration panel to manage and virtualize environments based on the SpinalCore technology.
Its built-in features include: 
* Structurated data definition and display,
* Real-time alerts and interaction, 
* Possibility to connect to external softwares and analytics,
* Collaborative work within a SpinalCore architecture,
* ...


## Installation

To use the SpinalAdmin easily, you need to install the SpinalCore framework available on <a href='https://github.com/spinalcom/spinal-framework' target='_blank'>Github</a>:
```
git clone https://github.com/spinalcom/spinal-framework.git
```

Change the name of the root folder "spinal-framework" to your system name.

Put your Spinalhub executable (spinalhub_x64_vX.X) downloaded on www.spinalcom.com in the folder.

Run the Spinalhub with its default settings:
```
~/path/to/your-system$ make run
```
install the admin-dashboard organ


## Basic usage

The admin-dashboard is a node webkit application. To use it you need to :
  - compile the coffeScript source : cd SpinalAdmin; make
  - parameter the dashboard to connect on the rigth hub with the rigth user : conn = spinalCore.connect("http://168:JHGgcz45JKilmzknzelf65ddDftIO98P@127.0.0.1:8889/")
  - run the organ : cd admin-dashboard; ./organ run

<!--### Desk
![desk_files](https://cloud.githubusercontent.com/assets/14069348/16004140/571cf824-3160-11e6-8206-1263e00e4a5b.png)
![desk_projects](https://cloud.githubusercontent.com/assets/14069348/16004142/5898e03c-3160-11e6-8a9b-5673669fa4e9.png)

The desk panel allows you to handle files in your SpinalCore database and create projects, which correspond to a independant Lab.-->



