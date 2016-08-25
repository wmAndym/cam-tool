#!/usr/bin/perl -w
#usage:Run script in terminal: "script file" + "target cam ip address" + "output temp file path"
# this script is use to probe CAM information by parsing HTML report -- Jifu 2015/11/14
use File::Slurp;
use LWP::UserAgent;
use Data::Dumper;
use HTML::TokeParser;
use Foundation;
my %port2Signal=(
				"FPGA_EURO_34"=>"StartBtnPressed",
				 "FPGA_EURO_22"=>"LED_PASSS",
				 "FPGA_EURO_23"=>"LED_FAIL",
				 "FPGA_EURO_24"=>"LED_IN_PROCESS",
				 "FPGA_EURO_26"=>"AdapterSwitch",
				 "FPGA_EURO_27"=>"BatterySwitch",
				 "FPGA_EURO_18"=>"DrawerIn",
				 "FPGA_EURO_19"=>"DrawerOut",
				 "FPGA_EURO_20"=>"DrawerUp",
				 "FPGA_EURO_21"=>"DrawerDown",
				 );
my $target_ip=shift;
my $temp_file_path=shift || "/tmp/cam_info.plist";
my $output_dict = NSMutableDictionary->dictionary();
my $errorCodeKey =NSString->stringWithCString_("ErrorCode");
my $errorCodeValue =NSString->stringWithCString_("0");
$output_dict->setObject_forKey_($errorCodeValue, $errorCodeKey);
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
my $response = $ua->get("http://$target_ip/status.cgi");

if ($response->is_success) {
	my $document = $response->decoded_content;  # or whatever
	&parserHTML($document);
}
else {
	my $errorCodeKey =NSString->stringWithCString_("ErrorCode");
	my $errorCodeValue =NSString->stringWithCString_("1");
	$output_dict->setObject_forKey_($errorCodeValue, $errorCodeKey);
	print $response->status_line;
}

my $cam_info_path = NSString->stringWithCString_($temp_file_path);
$output_dict->writeToFile_atomically_($cam_info_path,1);
#my $userDefaults=NSUserDefaults->standardUserDefaults();
#my $key =NSString->stringWithCString_("cam_info");
#$userDefaults->setObject_forKey_($output_dict,$key);
sub parserHTML($)
{
			my $document=shift;
			my $p=HTML::TokeParser->new(\$document);
			my @datas=();
			my $camHeaderInfo = NSMutableDictionary->dictionary();
			my $camPortInfo = NSMutableArray->array();
			my %portInfo=();
			my %headerInfo=();
			while (my $token = $p->get_tag(("tr","td"))) {
				my $text=undef;
				#print Dumper($token);
				if($token->[0] eq "td")
				{
					$text = $p->get_trimmed_text("/td");
					#print "$text ";
					push @datas,$text;

				}elsif($token->[0] eq "tr"){
					if($#datas == 1){
						#print "Header:" .Dumper($datas[1]);
						$headerInfo{$datas[0]} = $datas[1];
						my $key = NSString->stringWithCString_($datas[0]);
						my $value =NSString->stringWithCString_($datas[1]);
   						$camHeaderInfo->setObject_forKey_($value, $key);
					}elsif($#datas== 5){
						#print  "Data" . Dumper(@datas);
						foreach my $i (0..1){
							(my $p = $datas[3*$i] )=~s/://g;
							my $sort_key = (split(/_/,$p))[2];
							$portInfo{$sort_key}=[$p,$datas[3*$i+1],$datas[3*$i+2]];
							
						}
					}
					@datas=();
				}
			}
			
			#sort port infomation.and then append to array.
			foreach my $key (sort{$a <=> $b} keys(%portInfo)){
				#print $key."\n";
				my $portNameKey = NSString->stringWithCString_("PortName");
				my $portValueKey =NSString->stringWithCString_("PortValue");
				my $portTypeKey = NSString->stringWithCString_("PortType");
				my $portSignalKey =NSString->stringWithCString_("PortSignal");
				
				my $dict = NSMutableDictionary->dictionary();
	
				my $portName = NSString->stringWithCString_($portInfo{$key}->[0]);
				my $portValue =NSString->stringWithCString_($portInfo{$key}->[1]);
				my $portType = NSString->stringWithCString_($portInfo{$key}->[2]);
				my $signal = $port2Signal{$portInfo{$key}->[0]} || $portInfo{$key}->[0];
				my $signalName = NSString->stringWithCString_($signal);
				$dict->setObject_forKey_($portName, $portNameKey);
				$dict->setObject_forKey_($portValue, $portValueKey);
				$dict->setObject_forKey_($portType, $portTypeKey);
				$dict->setObject_forKey_($signalName, $portSignalKey);
				$camPortInfo->addObject_($dict);
			}
			
			
			#print Dumper(%headerInfo);

			my $headerInfoKey = NSString->stringWithCString_("HeaderInfo");
			my $portInfoKey =NSString->stringWithCString_("PortInfo");

			$output_dict->setObject_forKey_($camHeaderInfo, $headerInfoKey);
			$output_dict->setObject_forKey_($camPortInfo, $portInfoKey);
			
}