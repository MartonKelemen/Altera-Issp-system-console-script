
# This script simplifies handling long issp sources. You can cut the issp source
#to custom sized parts, and then setting its values
#
# BEFORE USING THE SCRIPT:
#     - Create the proper ISSP module in your HDL design
#     - Set the global variables "issp_setting_source" and "issp_setting_probes"
#

#THE ELEMENTS OF issp_setting_source, ARE THE LOCATION OF THE LOWEST BITS OF THE ISSP SOURCES
#
#             src0      src1      src2    src3
#           | 32..26 | 25...19 | 18...8 | 7..0 |
#           set ::issp_setting_source [list 26 19 8 0]
#

#THE ARGUMENTUM OF send_packet ARE THE WISHED VALUES OF THE SOURCES. BE CATIOUS WHEN SETTING THE VALUES, YOU CAN SET HIGHER VALUES THEN .
#
#           send_packet 7 3 2 1
#

set   issp_index 0
set ::issp [lindex [get_service_paths issp] 0]
set ::claimed_issp [claim_service issp $issp mylib]


#set ::issp_setting_source [list 104 72 40 32 0]
#set ::issp_setting_probe  [list 104 72 40 32 0]

set ::issp_setting_source [list X .. X ]
set ::issp_setting_probe  [list X .. X ]


proc send_packet { args } {
    set index 0
    set issp_source 0
  foreach i $args {
      incr index
      set issp_source_$index $i
      puts "issp_source_$index : [expr \$issp_source_$index] "
  }
    set index 0
  foreach j $::issp_setting_source {
      incr index
      set issp_source_$index [expr  [expr \$issp_source_$index] *2**$j]
      puts "issp_source_$index : [expr \$issp_source_$index] "
  }
  for {set i 1} {$i<=$index} {incr i} {
      set issp_source [expr $issp_source+ [expr \$issp_source_$i] ]
  }
      puts "issp_source: $issp_source"

  issp_write_source_data $::claimed_issp $issp_source
  set current_source_data [issp_read_source_data $::claimed_issp]

  puts "Source data:"
  puts $current_source_data
}


proc read_probe { } {
  #reading out the value of probes
  #set current_probe_data [issp_read_probe_data $::claimed_issp]
  set current_probe_data [issp_read_source_data $::claimed_issp]
  puts "Probe data:"
  puts $current_probe_data

  #converting to proper format
  set temp $current_probe_data
  set index 0
  foreach i $::issp_setting_probe {
    set issp_probe_$index [expr $temp >> $i]
    set temp [expr $temp - [expr [expr \$issp_probe_$index] << $i ] ]
    puts "issp_probe_$index : [expr \$issp_probe_$index] "
    incr $index
  }

}
