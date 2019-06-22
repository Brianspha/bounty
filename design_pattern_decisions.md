I used Vue.js as my front end  

The design pattern i chose most of the time was the 
Component Registration explained below
This is used when you have frequently used components and have to import them for usage

Module Registration

Just like component registration mdules have to be imported and resgistered for usage

Lazy Loaded Routes

In some instance like when i had to import my compiled contracts i had to load these contract objects in  a lazy manner

With my backend 

Specifically javascript 

Guard Check 
I used require statements in almost all the smart contract functions to ensure that the input data was correct and adhered to solidity rules

Access Restrictions
I used this pattern to ensure that ony a bounty owner may end a dispute as well as ensure that certain requirements are met before anything related to a bounty or a user are fullfilled 
Like in the instance when a user has to be punished from using the platform

