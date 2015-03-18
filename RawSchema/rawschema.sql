CREATE TABLE Rater
(
	user_id SERIAL,
	email VARCHAR(90) NOT NULL,
	name VARCHAR(70) NOT NULL,
	join_date TIMESTAMP NOT NULL,
	type_id SMALLINT NOT NULL,
	reputation SMALLINT NOT NULL DEFAULT 1,
	PRIMARY KEY (user_id),
	FOREIGN KEY (type_id) REFERENCES RaterType(type_id)
		ON UPDATE CASCADE ON DELETE RESTRICT, --What do we want?
	CONSTRAINT rep_bounds CHECK (reputation >= 1 AND reputation <= 5),
	CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+[.][A-Za-z]$'),
		--Alphanumeric (with dot, underscore dash), 1 or more
		--then @
		--then alphanumeric (with dot, dash), 1 or more
		--then .
		--then alphabetic domain end (com, ca, etc.)
	CONSTRAINT valid_name CHECK (name ~* '^[A-Za-z][A-Za-z0-9 _-]$')
		--Alphanumeric (with space, dash, underscore), starts with a letter
);

CREATE TABLE RaterType
(
	type_id SERIAL,
	description TEXT NOT NULL,
	PRIMARY KEY (type_id)
);

CREATE TABLE Restaurant
(
	restaurant_id SERIAL,
	name VARCHAR(70) NOT NULL,
	cuisine SMALLINT NOT NULL,
	url TEXT, -- allow restaurant to have no URL
	PRIMARY KEY (restaurant_id),
	FOREIGN KEY (cuisine) REFERENCES CuisineType(cuisine_id)
		ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT valid_name CHECK (name ~* '^[A-Za-z][A-Za-z0-9 ]*$')
		--Stats with letter, then alphanumeric with spaces
);

CREATE TABLE CuisineType
(
	cuisine_id SERIAL,
	description TEXT NOT NULL,
	PRIMARY KEY (type_id)
);


CREATE TABLE Rating
(
	user_id INTEGER NOT NULL,
	post_date TIMESTAMP NOT NULL,
	price SMALLINT NOT NULL DEFAULT 0,
	food SMALLINT NOT NULL DEFAULT 0,
	mood SMALLINT NOT NULL DEFAULT 0,
	staff SMALLINT NOT NULL DEFAULT 0,
	comments TEXT NOT NULL, -- Must enter comments! Should we enforce a min. length?
	restaurant_id INTEGER NOT NULL,
	PRIMARY KEY (user_id, post_date),
	FOREIGN KEY (user_id) REFERENCES Rater(user_id)
		ON UPDATE CASCADE ON DELETE RESTRICT, --What do we want?
	FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
		ON UPDATE CASCADE ON DELETE CASCADE -- no restaurant, no ratings
	CONSTRAINT price_valid_rating CHECK (price >= 1 AND price <= 5)
	CONSTRAINT food_valid_rating CHECK (food >= 1 AND food <= 5)
	CONSTRAINT mood_valid_rating CHECK (mood >= 1 AND mood <= 5)
	CONSTRAINT staff_valid_rating CHECK (staff >= 1 AND staff <= 5)

	
);

CREATE TABLE Location
(
	location_id SERIAL,
	first_open_date TIMESTAMP NOT NULL,
	manager_name VARCHAR(70), --not sure about this
	phone_number CHAR(11), --not sure about this
	street_address TEXT, --not sure about this
	hour_open TEXT, --not sure about this
	hour_close TEXT, --not sure about this
	restaurant_id INTEGER NOT NULL,
	PRIMARY KEY (location_id),
	FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
		ON UPDATE CASCADE ON DELETE CASCADE, -- no restaurant = no location
	CONSTRAINT valid_phone CHECK (phone_number ~* '^(1-|)(\d{3}|\(\d{3}\))[-]?\d{3}[-]?\d{4}$')
		--Starts with '1-' or not
		--Followed by either '(XYZ)' or 'XYZ'
		--Followed by 0 or 1 hyphens, 3 digits, 0 or 1 hyphens, 4 digits
		-- Thoughts on simplifying this? (eg 16135550123)
);

CREATE TABLE MenuItem
(
	item_id SERIAL,
	name VARCHAR(70) NOT NULL,
	sort VARCHAR(8),
	category TEXT, -- make refer to another table?
	description TEXT, --not sure about this
	price DECIMAL(4,2),
	restaurant_id INTEGER NOT NULL,
	PRIMARY KEY (item_id),
	FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id)
		ON UPDATE CASCADE ON DELETE CASCADE, 
		-- if restaurant no longer exists, neither does the menu item!
	CONSTRAINT food_or_bev CHECK (sort='Food' OR sort='Beverage')
);

CREATE TABLE RatingItem
(
	user_id INTEGER NOT NULL,
	post_date TIMESTAMP NOT NULL,
	item_id INTEGER NOT NULL,
	rating SMALLINT NOT NULL,
	comments TEXT, -- allow to be null (?)
	PRIMARY KEY (user_id, post_date, item_id),
	FOREIGN KEY (user_id) REFERENCES Rater(user_id)
		ON UPDATE CASCADE ON DELETE RESTRICT, --What do we want?
	FOREIGN KEY (item_id) REFERENCES MenuItem(item_id)
		ON UPDATE CASCADE ON DELETE RESTRICT, --What do we want?
	CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5)
);