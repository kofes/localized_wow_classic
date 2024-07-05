-- make locales_gameobject.name_loc8 column capacity campatible with ru locales
ALTER TABLE locales_gameobject MODIFY name_loc8 VARCHAR(150);
