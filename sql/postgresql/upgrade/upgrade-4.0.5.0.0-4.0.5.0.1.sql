-- upgrade-4.0.5.0.0-4.0.5.0.1.sql
SELECT acs_log__debug('/packages/intranet-overtime/sql/postgresql/upgrade/upgrade-4.0.5.0.0-4.0.5.0.1.sql','');

-----------------------------------------------------------
-- Create the object type

SELECT acs_object_type__create_type (
	'im_user_overtime',		-- object_type
	'Overtime',			-- pretty_name
	'Overtimes',			-- pretty_plural
	'acs_object',			-- supertype
	'im_overtime_bookings',		-- table_name
	'overtime_booking_id',			-- id_column
	'intranet-overtime',		-- package_name
	'f',				-- abstract_p
	null,				-- type_extension_table
	'im_user_overtime_name'		-- name_method
);

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('im_user_overtime', 'im_overtime_bookings', 'overtime_booking_id');


-- Setup status and type columns for im_user_overtimes
update acs_object_types set 
	status_type_table = 'im_overtime_bookings',
	status_column = 'overtime_status_id', 
	type_column = 'overtime_type_id' 
where object_type = 'im_user_overtime';

drop table im_overtime_bookings;
create table im_overtime_bookings (
        overtime_booking_id     integer
                                constraint im_user_overtime_pk
                                primary key
				constraint im_user_overtime_id_fk
				references acs_objects,
        booking_date            date
                                constraint im_user_overtime_booking_date_nn
                                not null,
        user_id                 integer
                                constraint im_user_overtime_user_id_nn
                                not null
				constraint im_user_overtime_user_id_fk
				references users,
        comment			varchar(400), 
        days	                float,
	-- Status and type for orderly objects...
        overtime_type_id	integer
                                constraint im_user_overtimes_type_fk
                                references im_categories
                                constraint im_user_overtimes_type_nn
				not null,
        overtime_status_id	integer
                                constraint im_user_overtimes_status_fk
                                references im_categories
                                constraint im_user_overtimes_type_nn 
				not null

);

