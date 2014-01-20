# /packages/intranet-overtime/www/booking.tcl
#
# Copyright (C) 2011 ]project-open[
#

ad_page_contract {
    @param
    @author Klaus Hofeditz (klaus.hofeditz@project-open.com)
} {
    comment
    overtime
    { type "overtime" }
    {return_url ""}
}

# ---------------------------------------------------------------
# Defaults and Settings & Security  
# ---------------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]

if { ![exists_and_not_null return_url] && [exists_and_not_null user_id]} {
    set return_url "[im_url_stub]/users/view?[export_url_vars user_id]"
}

# --------------------------------------------
# Create Form
# --------------------------------------------

set form_id "overtime-new"
ad_form -name $form_id -action /intranet-overtime/new -cancel_url $return_url -form {
    overtime_booking_id:key
    user_id:text(hidden)
    {overtime_date:date(date) {label "[_ intranet-timesheet2.Start_Date]"} {format "YYYY-MM-DD"} {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('start_date', 'y-m-d');" >}}}
    {duration_days:float(text) {label "[lang::message::lookup {} intranet-timesheet2.Duration_days {Duration (Days)}]"} {help_text "[lang::message::lookup {} intranet-timesheet2.Duration_days_help {Please specify the absence duration as a number or fraction of days. Example: '1'=one day, '0.5'=half a day)}]"}}
    {comment:text(textarea),optional {label "[_ intranet-timesheet2.Description]"} {html {cols 40}}}
} 

# Planned units a number?
if {![string is double $overtime]} {
        ad_return_complaint 1 "
            <b>[lang::message::lookup "" intranet-core.Not_a_number "Value is not a number"]</b>:<br>
            [lang::message::lookup "" intranet-core.Not_a_number_msg "
                The value for you have provided for 'Overtime' ('$overtime') is not a number.<br>
                Please enter something like '1' or '0.5'.
	"]
        "
        ad_script_abort
}

if {![im_permission $user_id "view_hr"]} {
    ad_return_complaint 1 "[_ intranet-core.lt_Insufficient_Privileg]"
}

if {[catch { 
	     set overtime_booking_id [db_string nextval "select nextval('im_overtime_bookings_seq');"]
	     db_dml insert_inq "
                insert into im_overtime_bookings
                        (overtime_booking_id, booking_date, user_id, comment, days)
                values
                        ($overtime_booking_id, now(), :user_id_from_form, :comment, :overtime)
             "
             db_dml update_balance "
                update im_employees set overtime_balance = (select overtime_balance from im_employees where employee_id = :user_id_from_form) + :overtime where employee_id = :user_id_from_form 
             "
	   } errmsg 
]} {ad_return_complaint 1 "<br>Error when inserting overtime record, please get in touch with your System Administrator:<br>$errmsg<br><br>"}

ad_returnredirect "/intranet/users/view?user_id=$user_id_from_form"