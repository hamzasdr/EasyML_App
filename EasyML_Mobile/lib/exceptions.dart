/// Thrown when the log-in operation fails
class LoginException implements Exception{}

/// Thrown when server doesn't respond
class ServerCommunicationException implements Exception{}

/// Thrown when an object with a duplicate name is created
class DuplicateNameException implements Exception{}

/// Thrown when attempting to register and the username already exists
class UsernameAlreadyExistsException implements Exception{}

/// Thrown when attempting to register and the email already exists
class EmailAlreadyExistsException implements Exception{}