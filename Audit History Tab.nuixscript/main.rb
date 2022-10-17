import javax.swing.JPanel
import javax.swing.JTable
import javax.swing.JScrollPane
import javax.swing.GroupLayout
import javax.swing.JLabel
import java.awt.Dimension
import javax.swing.JLabel
import javax.swing.JButton
import javax.swing.JComboBox
#import javax.swing.ImageIcon

import javax.swing.SwingUtilities
import javax.swing.JFileChooser
java_import javax.swing.JOptionPane
require 'date'

def loadhelp()
	link="#{File.dirname(__FILE__)}\\Help.html"
	begin
		import com.teamdev.jxbrowser.chromium.Browser;
		import com.teamdev.jxbrowser.chromium.swing.BrowserView;
		body=JPanel.new(java.awt.GridLayout.new(0,1))
		browser=Browser.new()
		browser.cookieStorage().deleteAll()
		browserview=BrowserView.new(browser)
		body.add(browserview)
		browser.loadURL(link)
		$window.addTab("Help",body)
	rescue Exception => ex
		puts "jxbrowser isn't in this build of workstation"
		begin
			system "explorer \"#{link}\""
		rescue Exception => ex
			puts "Help is located here:\n#{link}"
		end
	end
end

def flat_hash(obj,f=[],g={})
	outputhash=Hash.new()
	begin
		obj=obj.to_h
		if(obj.keys.uniq.reject{|key,value|key.to_s.strip()==""}.length==0)
			obj=obj.values.join(";")
		end
	rescue
		begin
			obj=obj.to_a.values.join(";")
		rescue
			#who knows what it is... let's make it a string
			obj=obj.to_s
		end
	end
	return g.update({ f=>obj }) unless obj.is_a? Hash
	obj.each { |k,r| flat_hash(r,f+[k],g) }
	g
end

#save_file("some title","c:/",{"comma"=>"csv","text"=>"txt"})
def save_file (title="Choose File",loaddir="",extensions=Hash.new())
	file = nil
	chooser = javax.swing.JFileChooser.new
	chooser.dialog_title = title
	if(extensions.length > 0)
		extensions=extensions.map{|name,ext|javax.swing.filechooser.FileNameExtensionFilter.new(name,ext)}
		extensions.each do |ext| chooser.addChoosableFileFilter(ext) end
		chooser.setFileFilter(extensions.first)
	end
		
	chooser.file_selection_mode = JFileChooser::FILES_ONLY
	chooser.setCurrentDirectory(java.io.File.new("#{loaddir}"))
	if chooser.show_save_dialog(nil) == javax.swing.JFileChooser::APPROVE_OPTION
		file=chooser.selected_file.path
	end
	return file
end

def prompt_input(message,initialValue="")
	return JOptionPane.showInputDialog(message,initialValue);
end

def show_message(message,title="Message")
	puts "---#{title}---"
	puts message
	JOptionPane.showMessageDialog(nil,message,title,JOptionPane::PLAIN_MESSAGE)
end

def confirm_dialog(message,title="Confirm?")
	return JOptionPane.showConfirmDialog(nil,message,title,JOptionPane::YES_NO_OPTION) == JOptionPane::YES_OPTION
end

def export_table(obj)
	filename=save_file("Export to where?","",{"tab separated file (*.tsv)"=>"tsv"})
	if(!filename.nil?)
		if(!filename.end_with? ".tsv")
			filename="#{filename}.tsv"
		end
		#let's do the export
		open(filename,"w") do |f|
			columns=Array.new()
			0.upto(obj.getModel.getColumnCount()-2) do |i|
				columns.push obj.getModel().getColumnName(i)
			end
			f.puts columns.join("\t")
			columncount=obj.getModel().getColumnCount()
			rowcount=obj.getModel().getRowCount()
			0.upto(rowcount-1) do |row_item_index|
				row=Array.new()
				0.upto(columns.length-1) do |cell|
					row.push obj.getModel().getValueAt(obj.convertRowIndexToModel(row_item_index),cell)
				end
				f.puts row.join("\t")
			end
		end
	end	
end


def create_table(columns_Array,rows_Array,name)
	columnnames=java.util.Vector.new()
	columns_Array.each do | column|
		columnnames.add(column)
	end

	rowvalues=java.util.Vector.new()
	rows_Array.each do | row|
		rowvalue=java.util.Vector.new(1)
		row.each do | cell|
			rowvalue.addElement(cell)
		end
		rowvalues.addElement(rowvalue)
	end
	tb = JTable.new(rowvalues,columnnames)
	tb.name=name
	columncount=tb.getModel().getColumnCount()
					
	tb.getSelectionModel().addListSelectionListener do | event|
		if(!event.getValueIsAdjusting())
			case
				when (tb.name=="results")
					original_index=tb.getSelectedRows().first()
					if(original_index.nil?)
						#puts "found oddities when the table is refreshing... ignore"
					else
						sorted_index=tb.convertRowIndexToModel(original_index)
						history_event=tb.getModel().getValueAt(sorted_index,columncount-1)
						details=flat_hash(history_event.getDetails())
						0.upto(columncount-2) do |i|
							column_name=tb.getModel().getColumnName(i)
							details[["EventLog",column_name]]=tb.getModel().getValueAt(sorted_index,i)
						end
						$preview_table.getModel().setRowCount(0)
						details.each do | name,value|
							rowvalue=java.util.Vector.new(1)
							rowvalue.addElement(name.join("."))
							rowvalue.addElement(value.to_s)
							$preview_table.getModel().addRow(rowvalue)
						end
					end
				when (tb.name=="items")
					puts "items table clicked"
				else
					puts tb.name
			end
		end
	end
	tb.removeColumn(tb.getColumnModel().getColumn(columncount-1))
	return tb
end


def main_panel()
	panel=JPanel.new(java.awt.GridLayout.new(0,2))
	main_panel_results=results_panel()
	panel.add(main_panel_results)
	main_panel_preview=preview_panel()
	panel.add(main_panel_preview)
	return panel
end

def header_section()
	panel=JPanel.new()
	header_layout=GroupLayout.new(panel)
	panel.setLayout header_layout
	header_layout.setAutoCreateGaps(true)
	#header_layout.setAutoCreateContainerGaps(true);
	header_verticalSequentialGroups=header_layout.createSequentialGroup()
	header_horizontalSequentialGroups=header_layout.createSequentialGroup()
	header_vgroup=header_layout.createParallelGroup()
	header_verticalSequentialGroups.addGroup(header_vgroup)
	
	
	type_label=JLabel.new("Type:")
	header_hgroup_type_label=header_layout.createParallelGroup()
	header_horizontalSequentialGroups.addGroup(header_hgroup_type_label)
	header_hgroup_type_label.addComponent(type_label)
	header_vgroup.addComponent(type_label)
	
	$filter_by_type=JComboBox.new ["*","openSession","closeSession","loadData","search","annotation","export","import","delete","script","printPreview"].to_java
	header_hgroup_type_combo=header_layout.createParallelGroup()
	$filter_by_type.setMaximumSize Dimension.new 150, 20
	$filter_by_type.addActionListener do | actionevent|
		refresh(actionevent)
	end
	header_horizontalSequentialGroups.addGroup(header_hgroup_type_combo)
	header_hgroup_type_combo.addComponent($filter_by_type)
	header_vgroup.addComponent($filter_by_type)
	
	
	user_label=JLabel.new("User:")
	header_hgroup_user_label=header_layout.createParallelGroup()
	header_horizontalSequentialGroups.addGroup(header_hgroup_user_label)
	header_hgroup_user_label.addComponent(user_label)
	header_vgroup.addComponent(user_label)
	
	users=["*"]
	users.push *$current_case.getAllUsers().map{|user|user.getShortName()}
	$filter_by_user=JComboBox.new users.to_java
	$filter_by_user.setMaximumSize Dimension.new 150, 20
	$filter_by_user.addActionListener do | actionevent|
		refresh(actionevent)
	end
	header_hgroup_user_combo=header_layout.createParallelGroup()
	header_horizontalSequentialGroups.addGroup(header_hgroup_user_combo)
	header_hgroup_user_combo.addComponent($filter_by_user)
	header_vgroup.addComponent($filter_by_user)

	date_label=JLabel.new("After:")
	header_hgroup_date_label=header_layout.createParallelGroup()
	header_horizontalSequentialGroups.addGroup(header_hgroup_date_label)
	header_hgroup_date_label.addComponent(date_label)
	header_vgroup.addComponent(date_label)
	
	$filter_by_date=JComboBox.new ["Today","Previous Day","Previous Month","Previous Year","*"].to_java
	$filter_by_date.setMaximumSize Dimension.new 150, 20
	$filter_by_date.addActionListener do | actionevent|
		refresh(actionevent)
	end
	
	header_hgroup_date_combo=header_layout.createParallelGroup()
	header_horizontalSequentialGroups.addGroup(header_hgroup_date_combo)
	header_hgroup_date_combo.addComponent($filter_by_date)
	header_vgroup.addComponent($filter_by_date)

	header_layout.setVerticalGroup(header_verticalSequentialGroups)
	header_layout.setHorizontalGroup(header_horizontalSequentialGroups)
	return panel
end

def results_panel()
	columns=["Started","Ended","Performed by","Type of Event","Status","object"]
	rows=Array.new()
	$results_table=create_table(columns,rows,"results")
	jscroller = JScrollPane.new
	jscroller.getViewport.add $results_table
	$results_table.setAutoCreateRowSorter(true)
	results_panel=JPanel.new()
	results_layout=GroupLayout.new(results_panel)
	results_panel.setLayout results_layout
	results_layout.setAutoCreateGaps(true)
	results_horizontalSequentialGroups=results_layout.createSequentialGroup()
	results_verticalSequentialGroups=results_layout.createSequentialGroup()
	results_header_vgroup=results_layout.createParallelGroup()
	results_verticalSequentialGroups.addGroup(results_header_vgroup)
	results_main_vgroup=results_layout.createParallelGroup()
	results_verticalSequentialGroups.addGroup(results_main_vgroup)
	results_footer_vgroup=results_layout.createParallelGroup()
	results_verticalSequentialGroups.addGroup(results_footer_vgroup)
	results_hgroup=results_layout.createParallelGroup()
	results_horizontalSequentialGroups.addGroup(results_hgroup)

	
	header_panel=header_section()
	results_header_vgroup.addComponent(header_panel)
	results_hgroup.addComponent(header_panel)
	
	table_section=JPanel.new(java.awt.GridLayout.new(0,1))
	table_section.add (jscroller)
	results_main_vgroup.addComponent(table_section)
	results_hgroup.addComponent(table_section)

	export_section=JPanel.new(java.awt.GridLayout.new(0,4))
	export_section.setMaximumSize Dimension.new 999999999,30
	$results_blurb=JLabel.new("??")
	export_section.add($results_blurb)
	#lazy spacing
	export_section.add(JLabel.new(""))
	export_section.add(JLabel.new(""))
	#export button
	export_button=JButton.new()
	export_button.setText("Export View")
	export_button.addActionListener { |e|
		including_details=confirm_dialog("Include Details with Export (will take longer)?","Include Details?")
		if(including_details)
			#small problem... we have no idea what the possible columns are... so going to have to do a pre-check and export that...
			options=Hash.new()
			options["type"]=get_type()
			options["user"]=get_user()
			options["startDateAfter"]=get_start_date()
			options["startDateBefore"]=nil
			
			
			history=$current_case.getHistory(options).to_a
			#intentionally putting it out here so you can get the unique keys (pass one)
			export_hash=Hash.new()
			history.each do | history_event|
				flat_hash(history_event.getDetails()).keys.map{|key|"Eventlog.#{key.join(".")}"}.sort().each do | key|
					if(!(key=="Eventlog."))
						export_hash[key]=nil
					end
				end
			end
			#favourable column sort order with the important stuff up the front, and the long affected items at the end
			columns=["Started","Ended","User","Type","Status","Affected Items Count"]
			columns.push *export_hash.keys.sort()
			columns.push "Affected Items"
			
			filename=save_file("Export to where?","",{"tab separated file (*.tsv)"=>"tsv"})
			if(!filename.nil?)
				if(!filename.end_with? ".tsv")
					filename="#{filename}.tsv"
				end
				#let's do the export
				open(filename,"w") do |f|
					f.puts columns.join("\t")
					history.each do | history_event|
						export_hash=Hash.new()
						export_hash["Started"]=history_event.getStartDate()
						export_hash["Ended"]=history_event.getEndDate()
						export_hash["User"]=history_event.getUser()
						export_hash["Type"]=history_event.getTypeString()
						export_hash["Status"]=get_status(history_event)
						affected_items=history_event.getAffectedItems()
						flat_hash(history_event.getDetails()).each do |key,value|
							export_hash["Eventlog.#{key.join(".")}"]=value
						end
						export_hash["Affected Items Count"]=affected_items.length
						export_hash["Affected Items"]=affected_items.map{|item|item.getGuid()}.join(";")
						export_line=Array.new()
						columns.each do | column|
							export_line.push (export_hash[column].to_s.gsub(/[\n\r\t]+/,""))
						end
						f.puts export_line.join("\t")
					end
				end
				show_message("#{history.length} Audit History Logs exported","Export Complete")
			end
		else
			export_table($results_table)
		end
	}
	export_section.add(export_button)
	results_footer_vgroup.addComponent(export_section)
	results_hgroup.addComponent(export_section)

	results_layout.setVerticalGroup(results_verticalSequentialGroups)
	results_layout.setHorizontalGroup(results_horizontalSequentialGroups)
	return results_panel
end

def action_panel()
	action_panel = JPanel.new()
	action_layout=GroupLayout.new(action_panel)
	action_panel.setLayout action_layout
	action_layout.setAutoCreateGaps(true)
	action_horizontalSequentialGroups=action_layout.createSequentialGroup()
	action_verticalSequentialGroups=action_layout.createSequentialGroup()
	action_header_vgroup=action_layout.createParallelGroup()
	action_verticalSequentialGroups.addGroup(action_header_vgroup)
	action_main_vgroup=action_layout.createParallelGroup()
	action_verticalSequentialGroups.addGroup(action_main_vgroup)
	action_footer_vgroup=action_layout.createParallelGroup()
	action_verticalSequentialGroups.addGroup(action_footer_vgroup)
	action_hgroup=action_layout.createParallelGroup()
	action_horizontalSequentialGroups.addGroup(action_hgroup)

	#this does nothing? who added this grrrr
	#action_button=JButton.new()
	#action_button.setText("Go")
	#action_button.addActionListener { |e|
	#	puts "do action"
	#}
	#action_header_vgroup.addComponent(action_button)
	#action_hgroup.addComponent(action_button)
	
	option_panel=JPanel.new(java.awt.GridLayout.new(0,5))
	
	action_main_vgroup.addComponent(option_panel)
	action_hgroup.addComponent(option_panel)
	

	return action_panel
end


def preview_panel()
	columns=["Started","Ended","Performed by","Type of Event","Status","object"]
	rows=Array.new()
	$preview_table=create_table(columns,rows,"preview")
	columns=["Name","Value","object"]
	rows=Array.new()
	$preview_table=create_table(columns,rows,"metadata")
	jscroller_meta = JScrollPane.new
	jscroller_meta.getViewport.add $preview_table
	$preview_table.setAutoCreateRowSorter(true)
	preview_panel=JPanel.new()
	preview_layout=GroupLayout.new(preview_panel)
	preview_panel.setLayout preview_layout
	preview_layout.setAutoCreateGaps(true)
	preview_layout.setAutoCreateContainerGaps(true);
	preview_horizontalSequentialGroups=preview_layout.createSequentialGroup()
	preview_verticalSequentialGroups=preview_layout.createSequentialGroup()
	preview_header_vgroup=preview_layout.createParallelGroup()
	preview_verticalSequentialGroups.addGroup(preview_header_vgroup)
	preview_main_vgroup=preview_layout.createParallelGroup()
	preview_verticalSequentialGroups.addGroup(preview_main_vgroup)
	preview_footer_vgroup=preview_layout.createParallelGroup()
	preview_verticalSequentialGroups.addGroup(preview_footer_vgroup)
	preview_hgroup=preview_layout.createParallelGroup()
	preview_horizontalSequentialGroups.addGroup(preview_hgroup)

	
	header_panel=JLabel.new("Event Log Details")#JPanel.new(java.awt.GridLayout.new(0,))
	#header_panel.setMaximumSize Dimension.new 999999999,30
	#header_label=JLabel.new("Event Log Details")
	#header_panel.add(header_label)
	#help_pic=ImageIcon.new("#{File.dirname(__FILE__)}\\\\help.png","banner")
	#header_help=JLabel.new(help_pic)
	#header_panel.add(header_help)
	#header_help.setMaximumSize Dimension.new 999999999,20
	#header_help.addMouseListener { |e|
	#	if((e.clickCount==1))
	#		loadhelp()
	#	end
	#}
	preview_header_vgroup.addComponent(header_panel)
	preview_hgroup.addComponent(header_panel)
	
	table_section=JPanel.new(java.awt.GridLayout.new(0,1))
	table_section.add (jscroller_meta)
	preview_main_vgroup.addComponent(table_section)
	preview_hgroup.addComponent(table_section)

	action_section=JPanel.new(java.awt.GridLayout.new(0,3))
	action_section.setMaximumSize Dimension.new 999999999,30
	#lazy spacing
	action_section.add(JLabel.new(""))
	$go_action=JComboBox.new ["New Tab with affected items","Tag affected items","Custom Metadata affected items","Export Log Details","Export GUIDs of affected items","Help"].to_java
	$go_action.addActionListener do | actionevent|
		#I can't think of anything to do here... so stub
	end
	action_section.add($go_action)
	#action button
	action_button=JButton.new()
	action_button.setText("Go!")
	action_button.addActionListener { |e|
		if($go_action.getSelectedItem()=="Help")
			loadhelp()
		end
		original_index=$results_table.getSelectedRows().first()
		if(original_index.nil?)
			#puts "found oddities when the table is refreshing... ignore"
		else
			columncount=$results_table.getModel().getColumnCount()
			sorted_index=$results_table.convertRowIndexToModel(original_index)
			history_event=$results_table.getModel().getValueAt(sorted_index,columncount-1)
			if("Export Log Details"==$go_action.getSelectedItem())
				export_table($preview_table)
			else
				affected_items=history_event.getAffectedItems()
				if(affected_items.length ==0)
					show_message("No items were affected by this event log, unable to do action requested")
				else
					puts "items affected..."
					case ($go_action.getSelectedItem())
						when "New Tab with affected items"
							#Define our tab settings
							query="guid:(#{affected_items.map{|item|item.getGuid()}.join(" OR ")})"
							puts query
							settings = {
								"search" => query, #The query the tab will run and display results for
								"metadataProfile" => "Default", #A metadata profile object
							}
							#Show our tab which uses our custom profile
							puts "opening tab"
							$window.openTab("workbench",settings)
						when "Tag affected items"
							firstcolumn=history_event=$results_table.getModel().getValueAt(sorted_index,0)
							tagname=prompt_input("Tag Name","History_Event|#{firstcolumn}")
							annotater = $utilities.getBulkAnnotater
							annotater.addTag(tagname, affected_items)
							
						when "Custom Metadata affected items"
							firstcolumn=history_event=$results_table.getModel().getValueAt(sorted_index,0)
							meta_name=prompt_input("Custom Metadata Name","History_Event|#{firstcolumn}")
							meta_value=prompt_input("Custom Metadata value","History_Event|#{firstcolumn}")
							annotater = $utilities.getBulkAnnotater
							annotater.putCustomMetadata(meta_name, meta_value, affected_items,nil)
						when "Export GUIDs of affected items"
							filename=save_file("Export to where?","",{"text file (*.txt)"=>"text"})
							if(!filename.nil?)
								if(!filename.end_with? ".txt")
									filename="#{filename}.txt"
								end
								#let's do the export
								open(filename,"w") do |f|
									f.puts "GUID"
									f.puts affected_items.map{|item|item.getGuid()}.join("\n")
								end
							end
						else
							puts "Action was not found??"
							puts $go_action.getSelectedItem()
					end
				end
			end
		end
	}
	action_section.add(action_button)
	preview_footer_vgroup.addComponent(action_section)
	preview_hgroup.addComponent(action_section)

	preview_layout.setVerticalGroup(preview_verticalSequentialGroups)
	preview_layout.setHorizontalGroup(preview_horizontalSequentialGroups)
	return preview_panel
end

def get_type()
	if(!($filter_by_type.getSelectedItem()=="*"))
		return $filter_by_type.getSelectedItem().to_s
	end
	return nil
end

def get_user()
	if(!($filter_by_user.getSelectedItem()=="*"))
		return $filter_by_user.getSelectedItem().to_s
	end
	return nil
end

def get_start_date()
	if(!($filter_by_date.getSelectedItem()=="*"))
		case ($filter_by_date.getSelectedItem())
			when "Today"
				return Date.today
			when "Previous Day"
				return Date.today.prev_day
			when "Previous Month"
				return Date.today.prev_month
			when "Previous Year"
				return Date.today.prev_year
		end
	end
	return nil
end

def get_status(history_event)
	case
		when (history_event.getCancelled)
			return "Cancelled"
		when (history_event.getFailed)
			return "Failed"
		when (history_event.getSucceeded)
			return "Succeeded"
		else
			return ""
	end
end

def refresh(actionevent=nil)
	if($current_case.nil?)
		#weird Nuix bug where the case can suddenly become unset somehow.
		return
	end
	if(!actionevent.nil?)
		#puts "changed selection:#{actionevent.getSource.getSelectedItem()}"
	end
	#loading...
	$results_table.getModel().setRowCount(0)
	options=Hash.new()
	options["type"]=get_type()
	options["user"]=get_user()
	options["startDateAfter"]=get_start_date()
	options["startDateBefore"]=nil
	
	
	history=$current_case.getHistory(options).to_a
	history.each do | history_event|
		rowvalue=java.util.Vector.new(1)
		rowvalue.addElement(history_event.getStartDate())
		rowvalue.addElement(history_event.getEndDate())
		rowvalue.addElement(history_event.getUser())
		rowvalue.addElement(history_event.getTypeString())
		rowvalue.addElement(get_status(history_event))
		rowvalue.addElement(history_event)
		$results_table.getModel().addRow(rowvalue)
	end
	$results_blurb.setText("#{history.length} History Event items")
end





tab_panel = JPanel.new()
#I want to split tab_panel horizontally and display items matching the log entry below.
tab_layout=GroupLayout.new(tab_panel)
tab_panel.setLayout tab_layout
tab_layout.setAutoCreateGaps(true)
tab_layout.setAutoCreateContainerGaps(true);
tab_horizontalSequentialGroups=tab_layout.createSequentialGroup()
tab_verticalSequentialGroups=tab_layout.createSequentialGroup()
tab_main_vgroup=tab_layout.createParallelGroup()
tab_verticalSequentialGroups.addGroup(tab_main_vgroup)
tab_hgroup=tab_layout.createParallelGroup()
tab_horizontalSequentialGroups.addGroup(tab_hgroup)

tab_main_panel=main_panel()
tab_main_vgroup.addComponent(tab_main_panel)
tab_hgroup.addComponent(tab_main_panel)


tab_layout.setVerticalGroup(tab_verticalSequentialGroups)
tab_layout.setHorizontalGroup(tab_horizontalSequentialGroups)
$window.addTab("Audit History",tab_panel)

##first time detection

if(!(File.file?"#{File.dirname(__FILE__)}\\first_time_launched"))
	open("#{File.dirname(__FILE__)}\\first_time_launched","w") do |f|
		f.puts Time.now()
	end
	loadhelp()
	sleep(5)
end

## end first time detection

away=false
refresh()
invalid_secs=0
while(true)
	sleep(1)
	if(!tab_panel.getParent().isVisible())
		if(away==true)
			#puts "user has navigated away from this tab..."
		end
		away=false
	else
		if(away==false)
			#puts "user has navigated back to this tab... should I refresh?"
		end
		away=true
	end
	if($results_table.to_s.include? "invalid")
		invalid_secs=invalid_secs+1
		if(invalid_secs > 10)
			#bit of a long story here... so to keep it short the table does go invalid briefly when shifting between tabs... So... wait a few seconds to be sure the table remains invalid.
			puts "Closed Audit History Tab"
			exit
		end
	else
		invalid_secs=0
	end
end

