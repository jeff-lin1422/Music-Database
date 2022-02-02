create table cs210.song(
    song_title varchar(100),
    artist varchar(100),
    release_date date,
    genre varchar(80),
    album_title varchar(100),
    primary key(song_title, artist)
);

DROP TABLE cs210.user;
create table cs210.user(
    user_name varchar(100),
    primary key(user_name));

create table cs210.song_r(
    song_title varchar(100) NOT NULL,
    artist varchar(100) NOT NULL,
    user_name varchar(100) NOT NULL,
    song_rating tinyint NOT NULL,
    song_rat_date date NOT NULL,
    primary key(song_title, artist, user_name),
    FOREIGN KEY(song_title, artist) REFERENCES cs210.song(song_title, artist));

CREATE TABLE cs210.album(
	album_title VARCHAR(100) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    released_date DATE NOT NULL,
    PRIMARY KEY(album_title, artist)
);
create table cs210.album_r(
    album_title varchar(100) NOT NULL,
    artist varchar(100) NOT NULL,
    user_name varchar(100) NOT NULL,
    album_rating tinyint NOT NULL,
    album_rat_date date NOT NULL,
    primary key(album_title, artist, user_name),
    FOREIGN KEY (album_title, artist) REFERENCES cs210.album (album_title, artist));
DROP TABLE cs210.playlist;
CREATE TABLE cs210.playlist(
	user_name VARCHAR(100) NOT NULL,
    playlist VARCHAR(100) NOT NULL,
    playlist_create DATETIME NOT NULL,
    PRIMARY KEY(user_name, playlist)
);

create table cs210.playlist_content(
    user_name varchar(100) NOT NULL,
    playlist varchar(100) NOT NULL,
    song_title varchar(100) NOT NULL,
    artist varchar(100) NOT NULL,
    primary key(playlist, user_name, song_title),
    foreign key(song_title, artist) references 
                song(song_title, artist) );
DROP TABLE cs210.playlist_r;
create table cs210.playlist_r(
    user_name varchar(100) NOT NULL,
    playlist varchar(100) NOT NULL,
    playlist_rating tinyint NOT NULL,
    playlist_rat_date date NOT NULL,
    primary key(playlist, user_name),
    foreign key(user_name, playlist) references cs210.playlist(user_name, playlist),
	foreign key(user_name) references cs210.user(user_name));
SELECT * FROM cs210.music_database;
SELECT * FROM cs210.album;
SELECT * FROM cs210.album_r;
SELECT * FROM cs210.playlist;
SELECT * FROM cs210.playlist_r;
SELECT * FROM cs210.playlist_content ORDER BY playlist, user_name;
SELECT * FROM cs210.song;
SELECT * FROM cs210.song_r;
SELECT * FROM cs210.user;

SELECT * FROM cs210.user u JOIN cs210.song_r s ON u.user_name = s.user_name;

INSERT IGNORE INTO cs210.user(user_name)
	SELECT user_name FROM cs210.music_database WHERE user_name != '';
    
INSERT IGNORE INTO cs210.song (song_title, artist, release_date, genre, album_title) 
	SELECT ï»¿Song_title, Artist, release_date, genre, album_title
    FROM cs210.music_database;
    
INSERT INTO cs210.song_r(user_name, song_title, artist, song_rating, song_rat_date)
	SELECT user_name, ï»¿Song_title, Artist, song_rating, song_rat_date
    FROM cs210.music_database WHERE song_rating != "";
    
INSERT IGNORE INTO cs210.album_r(album_title, artist, user_name, album_rating, album_rat_date)
	SELECT Album_title, Artist, user_name, album_rating, album_rat_date
    FROM cs210.music_database WHERE Album_title != "" AND album_rating != '';

INSERT IGNORE INTO cs210.album(album_title, artist, released_date)
	SELECT Album_title, Artist, release_date
    FROM cs210.music_database WHERE Album_title != "";
    
INSERT IGNORE INTO cs210.playlist(user_name,playlist, playlist_create)
	SELECT user_name, playlist, playlist_date
    FROM cs210.music_database WHERE playlist != "";

INSERT IGNORE INTO cs210.playlist_r(user_name, playlist, playlist_rating, playlist_rat_date)
	SELECT user_name, playlist, playlist_rating, playlist_rat_date
    FROM cs210.music_database WHERE playlist != "" AND playlist_rating != '';
    
INSERT IGNORE INTO cs210.playlist_content(user_name, playlist, song_title, artist)
	SELECT user_name, playlist, ï»¿Song_title, Artist
    FROM cs210.music_database WHERE playlist != "";
#4)
SELECT genre AS "genre_name", COUNT(genre) AS "number of song ratings" FROM cs210.song_r sr 
	JOIN cs210.song s ON sr.song_title = s.song_title AND sr.artist = s.artist
    WHERE year(s.release_date) >= 2014 and year(s.release_date) <= 2022 GROUP BY genre
    ORDER BY COUNT(genre) DESC LIMIT 3; 
# relaxation, 4
# dance123 3.667
# dance songs 2.6
#5)
SELECT pl.user_name AS "username", pl.playlist, AVG(song_rating) AS 'average song rating' 
	FROM cs210.playlist_content pl JOIN cs210.song_r sr ON pl.user_name=sr.user_name
	AND pl.song_title = sr.song_title AND pl.artist = sr.artist GROUP BY playlist
	HAVING AVG(song_rating) >= 4.0;

#6)
# we dont care about individual ratings of song or album, so as long as a user rated something
# the union of the two tables will have all the ratings of users
# the result will have two jeff_lin because one of them contains space
SELECT song_title, user_name AS 'username', COUNT(song_rating) AS 'number of rating' FROM
	(SELECT * FROM cs210.song_r sr UNION SELECT * FROM cs210.album_r) t1
    GROUP BY user_name ORDER BY COUNT(song_rating) DESC LIMIT 5;
SELECT * FROM cs210.album_rating;
SELECT * FROM cs210.song;

#9)
SELECT genre, s.song_title, COUNT(s.song_title) AS "count of song in each genre"
	FROM cs210.song_r sr JOIN cs210.song s WHERE sr.artist = s.artist AND sr.song_title = s.song_title
    GROUP BY genre, song_title;



        # this gets all rated songs with its genre
# we want for each genre, get top n songs with the most rating

SELECT genre AS genre_name, song_title, number_of_ratings FROM (
SELECT s.genre, s.song_title, COUNT(s.song_title) AS number_of_ratings, ROW_NUMBER() OVER (PARTITION BY s.genre ORDER BY COUNT(s.song_title) DESC) AS new_rank
	FROM cs210.song_r sr JOIN cs210.song s ON sr.artist = s.artist 
    AND sr.song_title = s.song_title 
    GROUP BY s.song_title ORDER BY genre, COUNT(s.song_title) DESC) rank_table WHERE new_rank < 21;

SELECT new_song_title FROM (SELECT genre, song_title AS new_song_title FROM cs210.song)t1;

select album_title as album_name, avg(album_rating) as average_user_rating 
from cs210.album_r 
group by album_title
order by AVERAGE_USER_RATING DESC, album_title  ASC limit 10;

select album_title as album_name, avg(album_rating) as average_user_rating 
from album_r 
where year(album_rat_date) > 1990 and year(album_rat_date) < 1996 
group by album_title
order by AVERAGE_USER_RATING DESC, album_title  ASC limit 10;

SELECT EXTRACT(MONTH FROM '2017-08-26') = 8;