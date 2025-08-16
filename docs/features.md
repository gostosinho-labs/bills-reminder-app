# Bills Reminder App - Features Documentation

This document describes all the features and functionality of the Bills Reminder Flutter app. The app helps users track and manage their bills with smart notifications and reminders.

## Overview

The Bills Reminder app is a personal finance tool that helps users:
- Track upcoming bills and their due dates
- Set up notifications for bill reminders
- Mark bills as paid or pending
- View bills in a calendar format
- Manage recurring bills

## Core Features

### 1. Bill Management

#### Bill Entity
Each bill contains the following properties:
- **Name**: Description of the bill (e.g., "Electricity", "Rent")
- **Value**: Optional monetary amount
- **Date**: Due date for the bill
- **Notification**: Whether to send notifications for this bill
- **Recurrence**: Whether the bill repeats (monthly)
- **Paid**: Current payment status

#### Bill Operations
- **Create Bills**: Add new bills with all properties
- **Edit Bills**: Modify existing bill details
- **Delete Bills**: Remove individual bills or all bills at once
- **Mark as Paid/Pending**: Toggle payment status

### 2. Home Screen

The main screen features:
- **Tab Interface**: Separate views for "Pending" and "Paid" bills
- **Bill Lists**: Organized display of bills with due date indicators
- **Quick Actions**: 
  - Add new bill (floating action button)
  - Open calendar view
  - Access settings menu
- **Menu Options**:
  - Notification settings
  - Delete all bills
  - Create sample bills (debug mode only)

#### Visual Indicators
- Bills are color-coded based on their due date status
- Due date calculations show "today", "tomorrow", or specific dates
- Overdue bills are highlighted

### 3. Calendar View

- **Monthly Calendar**: Visual representation of bills by date
- **Month Navigation**: Switch between different months
- **Bill Indicators**: Visual markers showing bills on specific dates
- **Day Selection**: Tap dates to view bills for that day
- **Bill Details**: Access bill information directly from calendar

### 4. Notification System

#### Notification Types
1. **Startup Notifications**: Alert about due bills when app opens
2. **Per-Bill Notifications**: Individual reminders for each bill on due date
3. **Daily Notifications**: Daily summary of due bills

#### Notification Settings
- **Toggle Controls**: Enable/disable each notification type
- **Permission Handling**: Request and manage notification permissions
- **Background Processing**: Uses WorkManager for background notifications

#### Implementation Features
- Timezone handling for accurate scheduling
- Persistent notifications across app restarts
- Integration with system notification settings

### 5. Settings

#### Notification Preferences
- **On Startup**: Notify about due bills when app launches
- **Per Bill**: Individual notifications for each bill on due date
- **Daily Notification**: Daily reminders about due bills

### 6. Data Management

#### Local Storage
- **SQLite Database**: Local storage for all bill data
- **Shared Preferences**: User settings and preferences
- **Data Persistence**: All data stored locally on device

#### Data Operations
- Full CRUD operations for bills
- Efficient querying and filtering
- Data validation and error handling

## Technical Architecture

### Layer Structure
Following clean architecture principles:

1. **UI Layer** (`lib/ui/`):
   - Screens and widgets for user interface
   - View models for business logic
   - Form components and reusable widgets

2. **Domain Layer** (`lib/domain/`):
   - Bill model and business entities
   - Core business rules and validation

3. **Data Layer** (`lib/data/`):
   - Repositories for data access abstraction
   - Services for specific functionalities (database, notifications, background tasks)
   - Local implementations for storage and services

### Key Components

#### Services
- **BillsService**: Database operations for bills
- **NotificationService**: Local notification management
- **BackgroundService**: Background task scheduling
- **PreferenceService**: User settings management

#### Navigation
- **Go Router**: Declarative routing system
- **Route Management**: Centralized route definitions

#### State Management
- **Provider**: Dependency injection and state management
- **ChangeNotifier**: Reactive UI updates

## User Workflows

### Creating a Bill
1. Tap "+" floating action button
2. Fill in bill details (name, amount, date)
3. Configure notification and recurrence settings
4. Save bill

### Managing Bills
1. View bills on home screen (pending/paid tabs)
2. Tap bill to edit details
3. Mark as paid/pending with checkbox
4. Delete individual bills if needed

### Setting Up Notifications
1. Access settings from home screen menu
2. Configure notification preferences
3. Grant necessary permissions
4. Notifications automatically scheduled

### Calendar Navigation
1. Tap calendar icon from home screen
2. Navigate between months
3. View bills for specific dates
4. Access bill details from calendar

## Debug Features

### Development Tools
- **Sample Bill Creation**: Generate test data for development
- **Logging**: Comprehensive logging throughout the app
- **Debug Menu**: Additional options in debug builds

## Storage and Privacy

### Data Storage
- All data stored locally on device
- No cloud synchronization or external data sharing
- SQLite database for bill storage
- Shared preferences for user settings

### Privacy
- No personal data transmitted externally
- No analytics or tracking
- Notification permissions requested only when needed

## Technical Dependencies

### Core Dependencies
- **Flutter**: UI framework
- **Go Router**: Navigation
- **Provider**: State management
- **SQLite**: Local database
- **Flutter Local Notifications**: Push notifications
- **WorkManager**: Background tasks
- **Timezone**: Date/time handling
- **Shared Preferences**: Settings storage

## Future Enhancement Opportunities

### Potential Features
- Cloud backup and synchronization
- Bill categories and tags
- Spending analytics and reports
- Multiple currency support
- Bill photo attachments
- Payment method tracking
- Budget planning integration
- Export/import functionality
- Widget support for home screen
- Dark/light theme customization

### Technical Improvements
- Offline-first architecture
- Enhanced error handling
- Performance optimizations
- Accessibility improvements
- Internationalization support
- Advanced notification scheduling
- Data encryption options

## Development Guidelines

### Adding New Features
When implementing new features, follow the established architecture:

1) UI layer: displays data to the user that is exposed by the business logic layer, and handles user interaction. This is also commonly referred to as the "presentation layer".
2) Logic layer: implements core business logic, and facilitates interaction between the data layer and UI layer. Commonly known as the "domain layer".
3) Data layer: manages interactions with data sources, such as databases or platform plugins. Exposes data and methods to the business logic layer.

Using existing features as examples, like [home_screen.dart](mdc:lib/ui/home/home_screen.dart) (UI), [home_view_model.dart](mdc:lib/ui/home/home_view_model.dart) (logic layer), and [bills_service.dart](mdc:lib/data/services/bills/bills_service.dart) (data layer). Notice that, in the data layer, the actual storage changes and it may be a database, an API, etc.

It's required that the UI and logic layer have a 1-to-1 match (each screen must have one view model). It's not needed to have a 1-to-1 match between all layers. For example, the data layer may serve multiple features on multiple view models.

Each layer must only communicate with the immediate next layer (for example, the UI can't use the service layer directly).

### Testing

It's required to add unit tests for all new features and bug fixes. Follow these guidelines:

1) Write tests for the UI layer using widget tests.
2) Write tests for the logic layer using unit tests.
3) Write tests for the data layer using integration tests.

### Code Organization
- Maintain separation of concerns between layers
- Use dependency injection through Provider
- Follow existing naming conventions
- Implement proper error handling and logging

This documentation serves as a comprehensive reference for understanding the current app functionality and planning future enhancements.