# Live journey

Everything under `test/` runs on fakes: none of it talks to the backend. This folder holds the
one check that does. The app's real wiring (the service locator, the production Dio and its
interceptors, the repositories, the auth bloc) runs against the real Laravel API, and the
manager lives a working day:

a wrong password refused → sign in, on the home page → a driver, a restaurant and an operator
sign up and confirm their emailed codes: they wait, their apps closed to them → the driver and
the operator are let in; the restaurant is refused with a reason its app reads → an account
decided already cannot be decided again → the driver is suspended, their app closed, then let
back in → the users list by role, by status and by name → a coupon zone around the customer's
street, made wider → the coupon form offers every restaurant → a coupon for the restaurant in
that zone takes 20 % off the customer's order; the zone switched off, the coupon is refused at
that door → the delivery zone around the door switched off: the door can no longer be
delivered; switched on again → another delivery zone made, widened and deleted → the
platform's share of the food raised to 15 %: an order delivered afterwards pays
15 %, then the share goes back → the customer rates it → today's orders, money, deliveries and
ratings, as the statistics pages ask for them; the restaurant's stars are its customers'
ratings → who owes the platform: the restaurant by its own id, the driver by theirs → the
restaurant's payment recorded: it owes nothing more → the driver pays from their app, the
manager confirms it, and a second answer is refused in the app's language → the coupon's
order delivered: the platform owes the restaurant the 20 % it took off; paying more is refused,
in the app's language; paid, it owes nothing more, and the restaurant's archive lists the
payment → the account's name and phone corrected → sign out → a forgotten password reset by emailed code, and signed
in with the new one.

The customer, the restaurant, the drivers and the operators play their part through the API
with their own accounts, as their apps would. Only the phone is faked: storage, Firebase. So it
does **not** cover push notifications, Google sign-in, or the release build on a real device.
The statistics pages call the server themselves: the journey asks what they ask, with the
app's Dio, and checks the numbers.

## Running it

It is not part of `flutter test`. Run it before a release, about a minute:

1. Prepare the throwaway database, in `delivery_backend`:

   ```bash
   php artisan tinker --execute="require base_path('tests/LiveJourney/prepare.php');"
   ```

   It rebuilds `delivery_testing` (the database the backend tests use, never `delivery_db`)
   with a delivery zone, an open restaurant with its menu, and the accounts the journey needs:
   a manager, an operator, a customer, a restaurant and its driver. The driver, the restaurant
   and the operator who join the platform sign up by themselves.

2. Serve that database on its own port, in `delivery_backend`, in a terminal you close afterwards:

   ```bash
   # Git Bash
   DB_DATABASE=delivery_testing MAIL_MAILER=array QUEUE_CONNECTION=sync php artisan serve --port=8011 --no-reload
   ```

   ```powershell
   # PowerShell
   $env:DB_DATABASE='delivery_testing'; $env:MAIL_MAILER='array'; $env:QUEUE_CONNECTION='sync'
   php artisan serve --port=8011 --no-reload
   ```

3. Run the journey, here:

   ```bash
   flutter test test_live --dart-define=LIVE_API=http://127.0.0.1:8011/api
   ```

   The app asks the server for Arabic, as a phone that never chose a language does, and the
   server answers in it. To run the day with the app in French, add
   `--dart-define=LIVE_LANGUAGE=fr` (or `en`).

Run step 1 again before each run: the journey changes the manager's password at its end, and
expects no payment waiting.

Stop the server before running the backend's own tests (`php vendor/bin/pest`): they rebuild
the same database.

## The emailed codes

The test server sends no mail (`MAIL_MAILER=array`). The journey reads the code the server
stored with `php tests/LiveJourney/emailed_code.php EMAIL [verification|password_reset]` in
`delivery_backend`, which reads `delivery_testing` only. Pass
`--dart-define=LIVE_BACKEND=path/to/delivery_backend` when the backend is not next to this app,
and `php` must be on the PATH.

## Safety

The journey creates accounts, coupons and payments, and changes a setting, so it refuses to
start unless the server answers with the marker the prepare script wrote (`contact_website` =
`live-check.test`). Pointed at the development server or a real one, it stops before sending
anything. The commission it raises to 15 % is put back before the journey goes on.

## Good to know

- The server counts sign-ins per account (five a minute), with thirty a minute for one
  address: everyone in the journey signs in from this PC without waiting for one another.
- The customer of the journey is a new one: every order waits for an operator, who lets it
  through.
- "Today" is the phone's day, as the statistics' filter counts it; the server counts the same
  day on Algiers' clock (`LocalTime`), so an order placed just after midnight is today's.
- The others' requests carry no language, so the server answers them in English.
- A failure prints what the app would show the manager, or what the server answered to the
  others. A passing run prints the server's sentences, in the language asked: read them once
  in French and in Arabic before a release.
