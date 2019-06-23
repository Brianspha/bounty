I avoided using loops to ensure that my contract is not susceptible to block gas limit attacks

I used arrays to combat this isntead of having to loop through the dataset i return it to the client so he/she may loop through it outside of the blockchain and do as they please

I avoided using if statements for requirement checking as they are not atomic require statements on the other hand are atomic which is why i favored them


However i do believe giving the owner the rights to delete a user could introduce problems like the front running attack however this could not be avoided because users how abuse the bounty platform have to be punished