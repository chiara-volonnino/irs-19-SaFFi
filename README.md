# SaFFi - SwArm FireFighters
Project for the course of "Intelligent Robotic Systems" AA.2018/2019

https://www.unibo.it/en/teaching/course-unit-catalogue/course-unit/2019/412681

## About the project 
With this project we are going to tackle the use of a robot swarm to perform the typical actions needed in order to extinguish a fire, normally taken by human firefighters.

## Use Requirements

In order to use this application, download and install:
* **Argos simulator** (https://www.argos-sim.info/download.php)

## Run
In order to run the project in small arena configuration use:
`
	argos3 -c fire_fighters_small_arena.argos
`

To run the project in large arena configuration use:
`
	argos3 -c fire_fighters_large_arena.argos
`

It's possible to add walls to increase the difficulty level of the simulation. A first implementation is present in the respective argos files in the section entitled *walls configuration*, to uncomment this section and run project.

## Documentation
A brief presentation and a demo of the system can be found in doc folder: 

## Team members
Chiara Volonnino (chiara.volonnino@studio.unibo.it)  
Nicola Atti (nicola.atti@studio.unibo.it)
