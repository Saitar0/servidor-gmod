sAdmin = sAdmin or {}

sAdmin.config = sAdmin.config or {}

--   ______                                   
--  / _____) _                                
-- ( (____ _| |_ ___   ____ _____  ____ _____ 
--  \____ (_   _) _ \ / ___|____ |/ _  | ___ |
--  _____) )| || |_| | |   / ___ ( (_| | ____|
-- (______/  \__)___/|_|   \_____|\___ |_____)
--                               (_____|      

sAdmin.config["storage_type"] = "sql_local" --- sql_local or mysql

sAdmin.config["mysql_info"] = {
    host = "",
    port = 3306,
    database = "",
    username = "",
    password = ""
}