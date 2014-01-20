-- /packages/intranet-overtime/sql/postgresql/intranet-overtime-create.sql
--
-- Copyright (c) 2011 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author klaus.hofeditz@project-open.com

---------------------------------------------------------
-- Components
---------------------------------------------------------

-- Component in member-add page
--
SELECT im_component_plugin__new (
	null,					-- plugin_id
	'im_component_plugin',			-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'Overtime Balance Component',		-- plugin_name
	'intranet-overtime',			-- package_name
	'left',					-- location
	'/intranet/users/view',			-- page_url
	null,					-- view_name
	200,					-- sort_order
	'im_overtime_balance_component -user_id_from_search $user_id',
	'lang::message::lookup "" intranet-overtime.OvertimeBalanceComponent "Overtime Balance Component"'
);


SELECT im_component_plugin__new (
        null,                                   -- plugin_id
        'im_component_plugin',                  -- object_type
        now(),                                  -- creation_date
        null,                                   -- creation_user
        null,                                   -- creation_ip
        null,                                   -- context_id
        'RWH Balance Component',	           	-- plugin_name
        'intranet-overtime',                    -- package_name
        'left',                                 -- location
		'/intranet/users/view',					-- page_url
        null,                                   -- view_name
        210,                                    -- sort_order
        'im_rwh_balance_component -user_id_from_search $user_id',
        'lang::message::lookup "" intranet-overtime.RwhBalanceComponent "RWH Balance Component"'
);


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS '
 
declare
        v_plugin_id             integer;
	v_employees		integer; 
begin

	select group_id into v_employees from groups where group_name = ''Employees'';

        select  plugin_id
        into    v_plugin_id
        from    im_component_plugins pl
        where   plugin_name = ''RWH Balance Component'';
 
        PERFORM im_grant_permission(v_plugin_id, v_employees, ''read'');
 
        select  plugin_id
        into    v_plugin_id
        from    im_component_plugins pl
        where   plugin_name = ''Overtime Balance Component'';

        PERFORM im_grant_permission(v_plugin_id, v_employees, ''read'');

        return 1;
 
end;' LANGUAGE 'plpgsql';
 
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_employees'' and lower(column_name) = ''overtime_balance'';

        if v_count > 0 then 
	    RAISE NOTICE ''Notice: intranet-overtime-create.sql - column overtime_balance already exists'';
	else 
	       alter table im_employees add column overtime_balance numeric(12,2) DEFAULT 0;
	end if;

        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_employees'' and lower(column_name) = ''rwh_days_last_year'';

        if v_count > 0 then 
	    RAISE NOTICE ''Notice: intranet-overtime-create.sql - rwh_days_last_year already exists'';
	else 
	       alter table im_employees add column rwh_days_last_year numeric(12,2) DEFAULT 0;
	end if;

        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_employees'' and lower(column_name) = ''rwh_days_per_year'';

        if v_count > 0
        then
                RAISE NOTICE ''Notice: intranet-overtime-create.sql - column rwh_balance already exists'';
        else
                alter table im_employees add column rwh_days_per_year numeric(12,2) DEFAULT 0;
        end if;

        select count(*) into v_count from user_tab_columns
        where lower(table_name) = ''im_employees'' and lower(column_name) = ''overtime_balance'';

        if v_count > 0
        then
                RAISE NOTICE ''Notice: intranet-overtime-create.sql - column overtime_balance exists'';
        else
                alter table im_employees add column overtime_balance numeric(12,2) DEFAULT 0;
        end if;

        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


create or replace function inline_0 ()
returns integer as '
declare
        v_count                 integer;
begin
        select count(*) into v_count from im_view_columns where column_id = 5634;
        if v_count > 0
        then
                RAISE NOTICE ''Error in intranet-overtime-create.sql: Column ID 5634 already exists'';
        else
		insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
		sort_order) values (5634,56,''Reduced Working Hours (year)'',''$rwh_days_per_year'', 36);
        end if;
        return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-----------------------------------------------------------
-- Create the object type

SELECT acs_object_type__create_type (
	'im_overtime_booking',		-- object_type
	'Overtime',			-- pretty_name
	'Overtimes',			-- pretty_plural
	'acs_object',			-- supertype
	'im_overtime_bookings',		-- table_name
	'overtime_booking_id',			-- id_column
	'intranet-overtime',		-- package_name
	'f',				-- abstract_p
	null,				-- type_extension_table
	'im_overtime_booking_name'		-- name_method
);

insert into acs_object_type_tables (object_type,table_name,id_column)
values ('im_overtime_booking', 'im_overtime_bookings', 'overtime_booking_id');


-- Setup status and type columns for im_user_overtimes
update acs_object_types set 
	status_type_table = 'im_overtime_bookings',
	status_column = 'overtime_status_id', 
	type_column = 'overtime_type_id' 
where object_type = 'im_overtime_booking';

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


create or replace function im_overtime_booking__new (
	integer, varchar, timestamptz,
	integer, varchar, integer,
	varchar, integer, timestamptz,
	integer, integer, varchar, float
) returns integer as '
DECLARE
	p_overtime_booking_id		alias for $1;		-- overtime_booking_id  default null
	p_object_type   	alias for $2;		-- object_type default ''im_overtime_booking''
	p_creation_date 	alias for $3;		-- creation_date default now()
	p_creation_user 	alias for $4;		-- creation_user default null
	p_creation_ip   	alias for $5;		-- creation_ip default null
	p_context_id		alias for $6;		-- context_id default null

	p_absence_name		alias for $7;		-- absence_name
	p_user_id		alias for $8;		-- owner_id
	p_booking_date		alias for $9;
	p_absence_status_id	alias for $10;
	p_absence_type_id	alias for $11;
	p_comment		alias for $12;
 	p_days			alias for $13;

	v_absence_id	integer;
BEGIN
	v_absence_id := acs_object__new (
		p_overtime_booking_id,		-- object_id
		p_object_type,		-- object_type
		p_creation_date,	-- creation_date
		p_creation_user,	-- creation_user
		p_creation_ip,		-- creation_ip
		p_context_id,		-- context_id
		''f''			-- security_inherit_p
	);

	insert into im_overtime_bookings (overtime_booking_id, booking_date, 
	       user_id, comment, days,
	       overtime_status_id, overtime_time_id
	       ) values (
	       v_absence_id, p_booking_date, p_user_id,p_comment,p_days,
	       p_absence_status_id, p_absence_type_id
	);

	return v_absence_id;
END;' language 'plpgsql';


create or replace function im_overtime_booking__delete(integer)
returns integer as '
DECLARE
	p_overtime_booking_id	alias for $1;
BEGIN
	-- Delete any data related to the object
	delete from im_overtime_bookings
	where	overtime_booking_id = p_overtime_booking_id;

	-- Finally delete the object iself
	PERFORM acs_object__delete(p_overtime_booking_id);

	return 0;
end;' language 'plpgsql';




------------------------------------------------------
-- Absences Permissions
--

-- add_absences makes it possible to restrict the absence registering to internal stuff
SELECT acs_privilege__create_privilege('add_overtime_bookings','Add Overtime Bookings','Add Overtime Bookings');
SELECT acs_privilege__add_child('admin', 'add_overtime_bookings');

-- view_overtime_bookings_all restricts possibility to see overtime_bookings of others
SELECT acs_privilege__create_privilege('view_overtime_bookings_all','View Overtime Bookings All','View Overtime Bookings All');
SELECT acs_privilege__add_child('admin', 'view_overtime_bookings_all');

-- Set default permissions per group
SELECT im_priv_create('add_overtime_bookings', 'HR Managers');
SELECT im_priv_create('view_overtime_bookings_all', 'HR Managers');

-----------------------------------------------------------
-- Type and Status
--
-- 5000 - 5099	Intranet Absence types
-- 16100-16199  Intranet Overtime Bookings (1000)
-- 16000-16099	Intranet Absence Status
-- 16100-16999	reserved

SELECT im_category_new (16100, 'Active', 'Intranet Overtime Status');
SELECT im_category_new (16102, 'Deleted', 'Intranet Overtime Status');
SELECT im_category_new (16104, 'Requested', 'Intranet Overtime Status');
SELECT im_category_new (16106, 'Rejected', 'Intranet Overtime Status');

SELECT im_category_new (5100, 'Overtime', 'Intranet Overtime Type');

