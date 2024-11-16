// Constants
const dbName = 'notes.db';
const fileTable = 'files';
const taskTable = 'tasks';
const deadlineTable = 'deadlines';
const projectTable = 'projects';

const userTable = 'user';
const emailColumn = 'email';

const idColumn = 'id';
const userIdColumn = 'user_id';
const titleColumn = 'title';

const subjectColumn = 'subject';
const descriptionColumn = 'description';
const contentColumn = 'content';
const typeColumn = 'type';

const dueDateColumn = 'due_date';
const dateColumn = 'date';
const startDateColumn = 'start_date';
const endDateColumn = 'end_date';

const isCompletedColumn = 'completed';

// Create User Table
const createUserTable = '''CREATE TABLE IF NOT EXISTS "$userTable" (
  "$idColumn" INTEGER NOT NULL,
  "$emailColumn" TEXT NOT NULL UNIQUE,
  PRIMARY KEY("$idColumn" AUTOINCREMENT)
);''';

// Create File Table
const createFileTable = '''CREATE TABLE IF NOT EXISTS "$fileTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" INTEGER NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$subjectColumn" TEXT,
  "$descriptionColumn" TEXT,
  "$contentColumn" TEXT NOT NULL,
  "$typeColumn" TEXT NOT NULL,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

// Create Task Table
const createTaskTable = '''CREATE TABLE IF NOT EXISTS "$taskTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" INTEGER NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$dueDateColumn" TEXT,
  "$isCompletedColumn" INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

// Create Deadline Table
const createDeadlineTable = '''CREATE TABLE IF NOT EXISTS "$deadlineTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" INTEGER NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$dateColumn" TEXT NOT NULL,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

// Create Project Table
const createProjectTable = '''CREATE TABLE IF NOT EXISTS "$projectTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" INTEGER NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$startDateColumn" TEXT NOT NULL,
  "$endDateColumn" TEXT NOT NULL,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';
