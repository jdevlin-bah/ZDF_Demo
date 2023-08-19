# ZDF Demo Repo
This repo houses a sample application to demonstrate the Zero Dependencies Framework. Here we make use of a custom object to represent reservations. On the insert of a reservation, a few things happen:
1. The record is classified as VIP or not based on Custom Metadata configuration stored in the ZD_ApplicationConfiguration__mdt custom metadata type.
2. Methods can also be stored in the  init_methods custom metadata record to call more methods on instantiation of the service via reflection.
3. A reminder task is created to confirm with the person the day before the reservation that its still active.
4. If a reservation is VIP, a chatGPT callout occurs and a special task is created for that VIP to impress them.

This all happens via the ReservationService, and the ReservationServiceTest tests every path within the Sample Service. The ReservationService and ReservationServiceTest are both able to be deployed to a fresh scratch org by themselves, nothing extra is required to install/deploy (minus ZDF of course).

## Examples
1. [ReservationService](https://github.com/jdevlin-bah/ZDF_Demo/blob/main/force-app/reservation-app/main/default/classes/scratch/ReservationService.cls) is an example Service class implementation built on the framework
2. [ReservationServiceTest](https://github.com/jdevlin-bah/ZDF_Demo/blob/main/force-app/reservation-app/main/default/classes/scratch/ReservationServiceTest.cls) includes test examples for testing every path the service can take
3. [QueryService](https://github.com/jdevlin-bah/ZDF_Demo/blob/main/force-app/reservation-app/main/default/classes/QueryService.cls) is an example of how to build an adaptor for code that you do not own but still want to include within your codebase in a loosely-coupled way.
4. [IntegrationTest](https://github.com/jdevlin-bah/ZDF_Demo/blob/main/force-app/reservation-app/main/default/classes/IntegrationTest.cls) is an example of a "classic" test with full inserts, hardcoded types, and multiple pieces of functionality happening. Still very much essential, but the number of these can be reduced by 90% or more.

## ZDF Repository
https://github.com/boozallen/zd-framework

## Commands
### Create Scratch Org
```
sf org create scratch -f config/project-scratch-def.json -a <YOUR ALIAS NAME>
```
### Full Setup
```
sf package install --package "ZDF" -w 5 -o <YOUR ALIAS NAME>
sf package install --package "TAF" -w 5 -o <YOUR ALIAS NAME>
sf project deploy start -d "force-app/unpackaged-dependencies" -o <YOUR ALIAS NAME>
sf project deploy start -d "force-app/reservation-app" -o <YOUR ALIAS NAME>
sf org assign permset --name Reservations_Permission_Set -o <YOUR ALIAS NAME>
sf org open -o <YOUR ALIAS NAME>
```
Then go to the reservation management app, add reservations and include preferences to test. Tasks get created on insert. If the deposit is over 500, the reservation gets marked as VIP. If there are more than 3 reservations in the last 30 days for a customer, it is also marked as a VIP. NOTE: If you want chat gpt to actually work, you will need to generate your own key and set in the named credential.

### Second Scratch Org (just the service deployed with ZDF)
```
sf org create scratch -f config/project-scratch-def.json -a <SECOND ALIAS>
sf package install --package "ZDF" -w 5 -o <SECOND ALIAS>
sf project deploy start -d "force-app/reservation-app/main/default/classes/scratch" -o <SECOND ALIAS>
```
### Run the test for the service
```
sf apex run test --class-names "ReservationServiceTest" --result-format human --code-coverage -w 2 -o <ALIAS> 
```

## Credits
Zero Dependencies Framework - https://github.com/boozallen/zd-framework <br/>
Trigger Actions Framework - https://github.com/mitchspano/apex-trigger-actions-framework <br/>
Apex Tool Kit - https://github.com/codefriar/ApexKit
