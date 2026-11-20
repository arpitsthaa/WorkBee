# MVC Pattern Guide

This project uses a simple MVC-style structure. MVC means:

- **Model** stores and organizes data.
- **View** displays the app screens and widgets.
- **Controller** handles screen actions and connects views to services.

## Folder Structure

```text
lib/
  main.dart
  models/
  views/
  controllers/
  services/
  widgets/
test/
```

## `lib/main.dart`

This is the app entry point.

Keep in this file:

- The `main()` function.
- The root `MaterialApp`.
- App theme and initial screen.

Do not place API calls or large screens here.

## `lib/models`

Models represent data used by the app.

Examples:

- Login response data.
- Student dashboard data.
- A student, gig, or project object.

Keep simple data classes here. Models should not call an API or build widgets.

Examples in this project:

- `auth_result.dart` stores login or registration results.
- `dashboard_model.dart` stores student dashboard data.

## `lib/views`

Views contain the screens users see.

Keep in this folder:

- Complete pages.
- Form fields and page layout.
- Button actions that call controller methods.
- Navigation between screens.

Views should not contain complex API request code.

Views are currently grouped by feature:

- `lib/views/auth/` contains login and registration screens.
- `lib/views/student/` contains the student dashboard.

Example file names:

```text
login_page.dart
student_register_page.dart
dashboard_page.dart
```

Use lowercase file names with underscores.

## `lib/controllers`

Controllers manage actions performed by a screen.

For example, a login controller:

1. Receives the email and password from the login view.
2. Calls the authentication service.
3. Updates loading or error state.
4. Returns the result to the view.

Keep here:

- Button action logic.
- Loading state.
- Error state.
- Calls to services.

Examples in this project:

- `auth_controller.dart` handles login and registration actions.
- `dashboard_controller.dart` handles loading dashboard data.

## `lib/services`

Services communicate with external systems.

Examples:

- Sending login requests.
- Registering a student or business.
- Loading dashboard data from an API.
- Waking up a hosted backend.

Keep API URLs, HTTP requests, JSON conversion, and network exceptions in this folder.

Services should not build widgets or navigate screens.

Examples:

- `auth_service.dart`
- `dashboard_service.dart`
- `backend_warmup_service.dart`

## `lib/widgets`

Widgets contains reusable UI components.

Keep here:

- Shared text fields.
- Shared buttons.
- Headers.
- Cards used by multiple screens.
- Shared app colors or theme values.

Do not put complete pages or API calls here.

Example:

- `auth_widgets.dart` contains reusable login and registration UI components.

## `test`

Keep automated tests here.

Examples:

- Testing that the login screen appears.
- Testing controller behavior.
- Testing model conversion.
- Testing service results with a fake API.

## Simple Example Flow

When a user logs in:

1. `login_page.dart` receives the email and password.
2. `auth_controller.dart` performs the login action.
3. `auth_service.dart` sends the API request.
4. `auth_result.dart` represents the returned result.
5. `login_page.dart` displays the result or opens the dashboard.

This keeps each part of the app responsible for one clear task.

## Beginner Rules

- Put API requests in `services`.
- Put data classes in `models`.
- Put screen behavior in `controllers`.
- Put screen layout in `views`.
- Put reusable UI components in `widgets`.
- Do not create a new folder unless it is needed for a clear responsibility.
