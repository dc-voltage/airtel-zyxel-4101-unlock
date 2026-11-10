var mainMenu=[
    {
        "title": "Home",
        "submenu": [
            {
                "title": "Connection Status",
                "url": "Home_connectionStatus.cgi"
            },
            {
                "title": "Data Usage",
                "url": "Home_dataUsage.cgi"
            },
            {
                "title": "LAN Status",
                "url": "Home_lanStatus.cgi"
            }
        ]
    },
    {
        "title": "Mobile Network",
        "submenu": [
            {
                "title": "Connect to Cells / Tower Lock",
                "url": "MobileNetworking_ConnectToCells.cgi"
            },
            {
                "title": "Network Search",
                "submenu": [
                    {
                        "title": "Automatic Network Search",
                        "url": "MobileNetworking_networkSearch_auto.cgi"
                    },
                    {
                        "title": "Manual Network Search",
                        "url": "MobileNetworking_networkSearch.cgi"
                    }
                ]
            },
            {
                "title": "APN Profile Setting",
                "url": "MobileNetworking_APNprofile.cgi"
            },
            {
                "title": "Roaming Setting",
                "url": "MobileNetworking_RoamingSetting.cgi"
            }
        ]
    },
    {   
        "title": "Connected Clients",
        "submenu": [        
            {  
                "title": "Client List",
                "url": "connected_clientList.cgi"
            }, 
            {  
                "title": "MAC Address Filtering",
                "url": "connected_MACaddress.cgi"
            }
        ]
    },
    {
        "title": "Settings",
        "submenu": [
            {
                "title": "LAN Settings",
                "submenu": [ 
                    {
                        "title": "DHCP Server",
                        "url": "Setting_lan_dhcpSetting.cgi"
                    }
                ]
            },
            {
                "title": "WAN & Routing",
                "submenu": [
                    {
                        "title": "Port Forwarding / Mapping",
                        "url": "Setting_wan_portMapping.cgi"
                    },
                    {
                        "title": "DMZ Host",
                        "url": "Setting_wan_dmz.cgi"
                    },
                    {
                        "title": "Dynamic DNS",
                        "url": "Setting_wan_dynamicDNS.cgi"
                    }
                ]
            },
            {
                "title": "Security & Firewall",
                "submenu": [
                    {
                        "title": "MAC Address Filter",
                        "url": "Setting_wan_macAddressFiltering.cgi"
                    },
                    {
                        "title": "URL Filter",
                        "url": "Setting_wan_urlFiltering.cgi"
                    }
                ]
            },
            {
                "title": "Device Management",
                "submenu": [ 
                    {
                        "title": "Reset Default Setting",
                        "url": "setting_resetDefaultSetting.cgi"
                    },
                    {
                        "title": "Reboot ODU",
                        "url": "setting_reboot.cgi"
                    }
                ]
            },
            {
                "title": "Bluetooth Beacon",
                "url": "setting_BluetoothUseCase.cgi"
            },
            {
                "title": "ACS Setting",
                "url": "Setting_acs.cgi"
            },
            {
                "title": "OpenWrt LuCI Engine",
                "url": "/cgi-bin/luci/"
            }
        ]
    },
    {
        "title": "Diagnostic",
        "submenu": [
            {
                "title": "Self Diagnostic Test",
                "url": "diagnostic_selfTest.cgi"
            },
            {
                "title": "Ping Test",
                "url": "diagnostic_pingTest.cgi"
            },
            {
                "title": "Trace Route Test",
                "url": "diagnostic_traceRouteTest.cgi"
            }
        ]
    },
    {
        "title": "About",
        "submenu": [
            {
                "title": "About Device",
                "url": "About.cgi"
            }
        ]
    }
];
