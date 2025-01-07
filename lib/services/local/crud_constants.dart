// Constants
const dbName = 'notes.db';
const fileTable = 'files';
const taskTable = 'tasks';
const tagsTable = 'tags';
const deadlineTable = 'deadlines';
const projectTable = 'projects';

const userTable = 'user';
const emailColumn = 'email';
const usernameColumn = 'username';
const experienceColumn = 'experience_points';
const openTimeColumn = 'last_opened';
const streakColumn = 'streak';
const sessionsColumn = 'sessions';

const idColumn = 'id';
const userIdColumn = 'user_id';
const titleColumn = 'title';

const subjectColumn = 'subject';
const descriptionColumn = 'description';
const contentColumn = 'content';
const typeColumn = 'type';
const lastOpenedColumn = 'last_opened';
const cloudIdColumn = 'cloud_id';

const dueDateColumn = 'due_date';
const dateColumn = 'date';
const startDateColumn = 'start_date';
const endDateColumn = 'end_date';

const isCompletedColumn = 'completed';

// Create Tables
const createUserTable = '''CREATE TABLE IF NOT EXISTS "$userTable" (
  "$idColumn" TEXT NOT NULL UNIQUE,
  "$emailColumn" TEXT NOT NULL UNIQUE,
  "$usernameColumn" TEXT,
  "$experienceColumn" INTEGER,
  "$openTimeColumn" TEXT NOT NULL,
  "$streakColumn" INTEGER,
  "$sessionsColumn" INTEGER,
  PRIMARY KEY("$idColumn")
);''';

const createFileTable = '''CREATE TABLE IF NOT EXISTS "$fileTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" TEXT NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$subjectColumn" TEXT NOT NULL,
  "$descriptionColumn" TEXT,
  "$contentColumn" TEXT NOT NULL,
  "$typeColumn" TEXT NOT NULL,
  "$lastOpenedColumn" TEXT NOT NULL,
  "$cloudIdColumn" TEXT,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

const createTaskTable = '''CREATE TABLE IF NOT EXISTS "$taskTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" TEXT NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$dueDateColumn" TEXT,
  "$isCompletedColumn" INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

const createTagsTable = '''CREATE TABLE IF NOT EXISTS "$tagsTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" TEXT NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

const createDeadlineTable = '''CREATE TABLE IF NOT EXISTS "$deadlineTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" TEXT NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$dateColumn" TEXT NOT NULL,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';

const createProjectTable = '''CREATE TABLE IF NOT EXISTS "$projectTable" (
  "$idColumn" INTEGER NOT NULL,
  "$userIdColumn" TEXT NOT NULL,
  "$titleColumn" TEXT NOT NULL,
  "$startDateColumn" TEXT NOT NULL,
  "$endDateColumn" TEXT NOT NULL,
  PRIMARY KEY("$idColumn" AUTOINCREMENT),
  FOREIGN KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn") ON DELETE CASCADE
);''';
