# Rails Assignment - Splitwise

## Details & Assumptions
- Using `JournalTransaction` for double entry book keeping of every transaction that happens in the system b/w two users.
- Due to time limitation skipped Friendship model b/w users and assuming all users present in system are friends. This is just for testing purposes. For this reason don't seed data instead create users from http://localhost:3000/users/sign_up
- Friend's expenses and User's expenses are built close to how [splitwise](https://www.splitwise.com/) does
- Edit functionality not implemented.
- Added limited specs due to time consideration
- There is lot of scope of refactoring but UI took more time than expected specially Expense form and the logic for showing various expense listing w.r.t logged in user.

## Setup
- Fork the repository. 
- Clone the repository in your local machine.
- Run `rails db:setup`, this will also seed data in the `User` model
- Run `rails s` to start the server and `rails c` for rails console

### Docker Setup
- copy `database.yml.example` to `database.yml`
- `docker-compose build`
- `docker-compose up`

## Requirements

- Ruby - 2.6.3
- Rails - 6.1.4
- Git (configured with your Github account)
- Node - 12.13.1


## Things available in the repo
- Webpacker configured and following packages are added and working.
  - Jquery
  - Bootstrap
  - Jgrowl
- Devise installed and `User` model is added. Sign in and Sign up pages have been setup.
- Routes and layouts for following page have been added.
  - Dashboard - This will be the root page.
  - Friend page - `/people/:id`


## Submission
- Make the improvements as specified in your technical assignment task.
- Commit all changes to the fork you created
- Deploy your app to Heroku
- Send us the link of the dpeloyed application and your fork.


## Contact us
If you need any help regarding this assignment or want to join [Commutatus](https://www.commutatus.com/), drop us an email at work@commutatus.com