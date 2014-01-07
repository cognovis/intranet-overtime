<form action="/intranet-overtime/booking">

<input type="hidden" name="user_id_from_form" value="@user_id_from_search@" />
<input type="hidden" name="type" value="overtime" />

<table>
<tr class=rowtitle>
	<td colspan=2 class=rowtitle><%= [lang::message::lookup "" intranet-overtime.Overtime_Balance "Overtime Balance"] %></td>
</tr>
<tr class=roweven>
	<td><%= [lang::message::lookup "" intranet-timesheet2.User User] %></td>
	<td>@user_name@</td>
</tr>
<tr class=rowodd>
	<td><%= [lang::message::lookup "" intranet-timesheet2.Time_Period "Period"] %></td>
	<td>@start_of_year@ - @end_of_year@</td>
</tr>

<tr class=roweven>
	<td><%= [lang::message::lookup "" intranet-overtime.Overtime_Days_Takeb "Days taken"] %></td>
	<td>@overtime_days_taken@</td>
</tr>

<tr class=rowodd>
        <td><%= [lang::message::lookup "" intranet-overtime.Overtime_Balance "Balance"] %></td>
        <td>@overtime_days_balance@</td>
</tr>

          <tr class="form-element">

            
                
                  <td class="form-label">
                
        <%= [lang::message::lookup "" intranet-overtime.Add_Overtime_date "Add Overtime for (date)"] %>
                
               </td>
 <td class="form-widget">
                <!-- date overtime_date begin -->
<input type="hidden" name="overtime_date.format" value="YYYY-MM-DD" >
<input type="text" name="overtime_date.year" id="overtime_date.year" size="4" maxlength="4" value="@current_year@">
-<select name="overtime_date.month" id="overtime_date.month" >
 <option value="">--</option>
 <option value="1">01</option>
 <option value="2">02</option>
 <option value="3">03</option>
 <option value="4">04</option>
 <option value="5">05</option>
 <option value="6">06</option>
 <option value="7">07</option>
 <option value="8">08</option>
 <option value="9">09</option>
 <option value="10">10</option>
 <option value="11">11</option>
 <option value="12">12</option>
</select>-<select name="overtime_date.day" id="overtime_date.day" >
 <option value="">--</option>
 <option value="1">01</option>
 <option value="2">02</option>
 <option value="3">03</option>
 <option value="4">04</option>
 <option value="5">05</option>
 <option value="6">06</option>
 <option value="7">07</option>
 <option value="8">08</option>
 <option value="9">09</option>
 <option value="10">10</option>
 <option value="11">11</option>
 <option value="12">12</option>
 <option value="13">13</option>
 <option value="14">14</option>
 <option value="15">15</option>
 <option value="16">16</option>
 <option value="17">17</option>
 <option value="18">18</option>
 <option value="19">19</option>
 <option value="20">20</option>
 <option value="21">21</option>
 <option value="22">22</option>
 <option value="23">23</option>
 <option value="24">24</option>
 <option value="25">25</option>
 <option value="26">26</option>
 <option value="27">27</option>
 <option value="28">28</option>
 <option value="29">29</option>
 <option value="30">30</option>
 <option value="31">31</option>
</select><!-- date overtime_date end -->
 <a href='/intranet-dynfield/attribute-new?attribute%5fid=59642&return%5furl=%2fintranet%2fusers%2fnew%3fuser%255fid%3d32179%26return%255furl%3d%252fintranet%252fusers%252fview%253fuser%255fid%253d32179'><img src="/intranet/images/navbar_default/wrench.png" border=0 title="" alt=""></a> <input type="button" style="height:20px; width:20px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('overtime_date', 'y-m-d');" ></b>
              

            </td>
          </tr>

<tr class=rowodd>
        <td><%= [lang::message::lookup "" intranet-overtime.Add_Overtime "Add Overtime (days)"] %></td>
        <td><input name="overtime" size="4" /></td>
</tr>

<tr class=roweven>
        <td><%= [lang::message::lookup "" intranet-core.Comment "Comment"] %></td>
        <td><input name="comment" size="20" /></td>
</tr>

<tr align="left">
        <td colspan=2><input value="<%=[lang::message::lookup "" intranet-core.Submit "Submit"]%>" type="submit"></td>
</tr>
</table>
</form>

<br>
<listtemplate name="overtime_balance"></listtemplate>

