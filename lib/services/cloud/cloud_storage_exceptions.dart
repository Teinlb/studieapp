class CloudStorageException implements Exception {
  const CloudStorageException();
}

// Create
class CouldNotCreateNoteException extends CloudStorageException {}

// Read
class CouldNotGetAllNotesException extends CloudStorageException {}

// Update
class CouldNotUpdateNoteException extends CloudStorageException {}

// Delete (CRUD)
class CouldNotDeleteNoteException extends CloudStorageException {}