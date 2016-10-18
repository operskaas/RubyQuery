CREATE TABLE vr_headsets (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  manufacturer_id INTEGER,

  FOREIGN KEY(manufacturer_id) REFERENCES company(id)
);

CREATE TABLE companies (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE vr_apps (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE app_compatibilities (
  id INTEGER PRIMARY KEY,
  headset_id INTEGER NOT NULL,
  app_id INTEGER NOT NULL,

  FOREIGN KEY(headset_id) REFERENCES vr_headsets(id),
  FOREIGN KEY(app_id) REFERENCES vr_apps(id)
);

INSERT INTO
  companies (id, name)
VALUES
  (1, "Oculus"),
  (2, "HTC"),
  (3, "Google"),
  (4, "Samsung");

INSERT INTO
  vr_headsets (id, name, manufacturer_id)
VALUES
  (1, "Rift CV1", 1),
  (2, "Rift DK2", 1),
  (3, "Gear VR", 4),
  (4, "Vive", 2),
  (5, "Cardboard", 3),
  (6, "Daydream", 3);

INSERT INTO
  vr_apps (id, name)
VALUES
  (1, "Space Pirate Trainer"),
  (2, "Keep Talking and Nobody Explodes"),
  (3, "Titans of Space Classic"),
  (4, "Netflix");

INSERT INTO
  app_compatibilities (id, headset_id, app_id)
VALUES
  (1, 1, 1),
  (2, 4, 1),
  (3, 1, 2),
  (4, 2, 2),
  (5, 4, 2),
  (6, 5, 2),
  (7, 2, 3),
  (8, 5, 3),
  (9, 3, 3),
  (10, 1, 4),
  (11, 3, 4),
  (12, 4, 4),
  (13, 6, 4);
