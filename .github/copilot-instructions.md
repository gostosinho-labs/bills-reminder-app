# When creating new features

Use the following architecture:

1) UI layer: displays data to the user that is exposed by the business logic layer, and handles user interaction. This is also commonly referred to as the "presentation layer".
2) Logic layer: implements core business logic, and facilitates interaction between the data layer and UI layer. Commonly known as the "domain layer".
3) Data layer: manages interactions with data sources, such as databases or platform plugins. Exposes data and methods to the business logic layer.

Using existing features as examples, like [home_screen.dart](mdc:lib/ui/home/home_screen.dart) (UI), [home_view_model.dart](mdc:lib/ui/home/home_view_model.dart) (logic layer), and [bills_service.dart](mdc:lib/data/services/bills/bills_service.dart) (data layer). Notice that, in the data layer, the actual storage changes and it may be a database, an API, etc.

It's required that the UI and logic layer have a 1-to-1 match (each screen must have one view model). It's not needed to have a 1-to-1 match between all layers. For example, the data layer may serve multiple features on multiple view models.

Each layer must only communicate with the immediate next layer (for example, the UI can't use the service layer directly).
