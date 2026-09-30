# SERC-SARGE
The Smithsonian Environmental Research Center's (SERC) Semi-Autonomous Radon and Greenhouse Gas Equilibrator (SARGE) a system for lateral flux and surface water monitoring studies. 

## Introduction to SARGE:
Lateral transport of constituents in coastal ecosystems remains largely unconstrained and is limited by a lack of long term, reproducible, and comparable datasets
The Semi-Autonomous Radon and Greenhouse gas Equilibration system (SARGE) is an adaptable system for monitoring water quality and lateral transport
The system is modular, records data using consistent timestamps and data structures, and can be adapted to specific monitoring goals 
SARGE’s open source code to log, stream, and visualize data in real time allows for adaptive management and supports reproducible science 

![Figure 1: SARGE system components](sarge_documentation/Wilson_etal_Figure1.png)


## What can SARGE do: 
SARGE can support instrumentation to measure the following:

- Water flow rate, direction, depth 
    - Xylem Sontek IQ ADCP
    - Could be adapted for other ADCPs
    
    
- Water physiochemical parameters (temp, salinity, pH, fDOM, turbidity, Chl)
    - YSI EXO2 Sonde 
    - Aquatroll600 
    - Could be adapted for other Sondes 
    
    
- Dissolved gases, which are equilibrated in a falling film equilibrator (Millet et al., 2019), including radon, methane, carbon dioxide, and nitrous oxide
    - Radon measured with RAD7 
    - RAD8 adaptation in progress 
    - Methane and carbon dioxide measured with either a LICOR 7810 or an LGR UGGA 
    - Nitrous oxide measured with a LICOR 7820 
    - Could be adapted for other greenhouse gas analyzers 
    
    
- These data are all collected from instrumentation in real-time by a data logger and transmitted via cell modem to the data hub 

- Real time data can be visualized using the SARGE shiny app 

- The system will support all of the mentioned data streams, but not all of them need to be used together. For example, the ADCP and sonde could be deployed with SARGE and none of the dissolved gas analyzers. 

![Figure 2. Flow diagram going from the equilibrator to the water trap with float switch, the desiccant, radon detector (RAD7), greenhouse gas analyzer, and back in a closed loop system.](sarge_documentation/Wilson_etal_Figure2.png)

## Where has SARGE been deployed: 

- Global Change Research Wetland (GCReW): Edgewater, MD, USA
    - long term deployment ~3 yrs 

- Smithsonian Environmental Research Center Dock: Edgewater MD, USA
    - long term deployment ~2 yrs 

- Sweet Hall Marsh (CBNERR site): West Point, VA, USA
    - Two week deployment 

- Goodwin Islands (CBNERR site): Gloucester Point, VA, USA
    - Two week deployment 

- Boca Chica: Key West, FL, USA 
    - Week long deployment 

- MacDill Base Tampa Bay: Tampa, FL, USA 
    - Week long deployment 

