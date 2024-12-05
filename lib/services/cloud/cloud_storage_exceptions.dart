class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotFetchFilteredFilesException extends CloudStorageException {}

class CouldNotGetFileException extends CloudStorageException {}

class CouldNotUploadOrUpdateFileException extends CloudStorageException {}

class CouldNotDeleteFileException extends CloudStorageException {}
