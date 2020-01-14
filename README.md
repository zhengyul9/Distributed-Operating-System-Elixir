Group members:

Zhengyu Li	29453969<br>
Yue Yu	96141901<br>

Video Link:

https://youtu.be/tMTmEA_VmFw or https://www.youtube.com/watch?v=tMTmEA_VmFw&t=1s

Run the code:
Run our project by creating user and use functionalities manually: 
1. Go to chat folder
2. Use mix phx.server
3. Open Browser and go to localhost:4000
4. Start to register account, login, send twitter etc. You can open multiple webpages stand for multiple users.

Create 100 users automatically and start their random behaviors:
1. Go to 100_users_simulation folder and go to chat_simulate_100 folder
2. Use mix phx.server
3. Open Browser and go to localhost:4000
4. Input the number of users and the number of random behaviors of each user

What is working?
The Twitter-like engine with all required functionalities is working. The maximum numbers of user we tested is 100. In this case, the speed is fast. The system can handle more and more users and operations, but takes more time. 

Functionalities:
1. Register account and delete account 
2. Send tweet. Tweets can have predefined hashtags (e.g. #COP5615isgreat) and mentions valid user(@user). 
3. Subscribe to user's tweets. 
4. Re-tweets. 
5. Querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned. 
6. Deliver the above types of tweets live, if the user is alive.

Test cases:
1. start server
2. register account
3. login
4. subscribe
5. send twitter and receive it without querying, if subscribed
6. mention and hashtags recognization
7. querying twitter with mentions
8. querying twitter with hashtags
9. re-tweets