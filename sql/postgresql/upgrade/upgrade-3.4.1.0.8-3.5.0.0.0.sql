-- upgrade-3.4.1.0.8-3.5.0.0.0.sql

SELECT acs_log__debug('/packages/intranet-rest/sql/postgresql/upgrade/upgrade-3.4.1.0.8-3.5.0.0.0.sql','');



----------------------------------------------------------------------
-- Category Hierarchy
----------------------------------------------------------------------

-- Create a report showing a category as a hierarchy.
--
SELECT im_report_new (
	'REST Category Type',						-- report_name
	'rest_category_type',						-- report_code
	'intranet-rest',						-- package_key
	120,								-- report_sort_order
	(select menu_id from im_menus where label = 'reporting-rest'),	-- parent_menu_id
'
select	im_category_path_to_category(category_id) as tree_sortkey,
	c.*
from	im_categories c
where	(c.enabled_p is null OR c.enabled_p = ''t'') and
	category_type = %category_type%
order by tree_sortkey
'
);

update im_reports 
set report_description = '
Returns a category type ordered by tree_sortkey
'
where report_code = 'rest_category_type';

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'rest_category_type'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);





----------------------------------------------------------------------
-- Permission "Report"
----------------------------------------------------------------------

-- The report shows all permission associated with a specific object.
-- The report expects an "object_id" parameter.
--
SELECT im_report_new (
	'REST Object Permissions',					-- report_name
	'rest_object_permissions',					-- report_code
	'intranet-rest',						-- package_key
	110,								-- report_sort_order
	(select menu_id from im_menus where label = 'reporting-rest'),	-- parent_menu_id
'
select	grantee_id, privilege
from	acs_permissions
where	object_id = %object_id%
'
);

update im_reports 
set report_description = '
Returns all permissions define for one object.
'
where report_code = 'rest_object_permissions';

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'rest_object_permissions'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



----------------------------------------------------------------------
-- Group Membership Report
----------------------------------------------------------------------

-- Show all groups to which a specific user belongs.
-- By default shows the groups for the current user.
-- Expects a "user_id" parameter.
--
SELECT im_report_new (
	'REST Group Memberships',					-- report_name
	'rest_group_membership',					-- report_code
	'intranet-rest',						-- package_key
	120,								-- report_sort_order
	(select menu_id from im_menus where label = 'reporting-rest'),	-- parent_menu_id
'
select	group_id
from	group_distinct_member_map
where	member_id = %object_id%
'
);

update im_reports 
set report_description = 'Returns all groups to which a user belongs.'
where report_code = 'rest_group_membership';

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'rest_group_membership'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);

