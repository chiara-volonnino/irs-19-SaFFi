# SaFFi - SwArm FireFighters
Project for the course of "Intelligent Robotic Systems" AA.2018/2019

https://www.unibo.it/en/teaching/course-unit-catalogue/course-unit/2019/412681

## About the project 
With this project we are going to tackle the use of a robot swarm to perform the typical actions needed in order to extinguish a fire, normally taken by human firefighters.

In this solution, we encountered an anomaly regarding the maximum range of reception of the *range_and_bearing* sensor, which is perceivable by the other robots only when within circa 100 cm, although they could communicate with the antenna robot from a lot farther away.
This caused the robots to orbit around the completed fire, and to never get too close to another light in order to perceive it as the most intense.
## Use Requirements

In order to use this application, download and install:
* **Argos simulator** (https://www.argos-sim.info/download.php)

## Run
In order to run the project use:
`
	argos3 -c beginnig.argos
`

## Documentation
A brief presentation and a demo of the system can be found in doc folder: 

## Team members
Chiara Volonnino (chiara.volonnino@studio.unibo.it)  
Nicola Atti (nicola.atti@studio.unibo.it)
