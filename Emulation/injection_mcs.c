/*
    Ruirong Chen @ pitt
    Injection with different MCS for emulation
    To compile
    gcc -o Injection_mcs Injection_mcs.c -lorcon2
    Emulated Payload is added @lcpa_append

*/
#include "/home/crr/MATLAB/R2020a/extern/include/mex.h"
#include <stdio.h>
#include <getopt.h>
#include <string.h>
#include <sys/time.h>
#include <arpa/inet.h>

#include <lorcon2/lorcon.h>
#include <lorcon2/lorcon_packasm.h>
#include <lorcon2/lorcon_forge.h>
/* MCS only goes 0-15 or 4 bits, so we use bits 6 and 7 to indicate if we
 * are sending HT40 and GI */
#define HT_FLAG_40  (1 << 7)
#define HT_FLAG_GI  (1 << 6)

#define PAYLOAD_LEN 64

void
mexFunction( int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
{
    char *interface = "wls4", *lname = NULL;
 	unsigned int lcode = 0;
    unsigned int npackets = 10000;

	int c;
    lorcon_channel_t channel;
    const char *channel_str;

	lorcon_driver_t *drvlist, *driver;
	lorcon_t *context;

	lcpa_metapack_t *metapack;
	lorcon_packet_t *txpack;

    // delay interval 
    unsigned int interval = 2;

   // Iterations through HT and GI 
    int mcs_iter = 0;
    int ht_iter = 1;
    int gi_iter = 0;
    unsigned int mcs_num = 0;
	unsigned int count = 0;
    
    unsigned int totalcount = 1;

    uint8_t *smac;

    uint8_t *bmac = "\x00\xDE\xAD\xBE\xEF\x00";

    uint8_t encoded_payload[14];
    uint32_t *encoded_counter = (uint32_t *) (encoded_payload + 2);
    uint32_t *encoded_max = (uint32_t *) (encoded_payload + 6);
    uint32_t *encoded_session = (uint32_t *) (encoded_payload + 10);
    
    uint8_t payload[PAYLOAD_LEN];

	// Timestamp
    struct timeval time;
    uint64_t timestamp;

	// Beacon Interval
	int beacon_interval = 1;

	// Capabilities
	int capabilities = 0x6422;

    // Session ID
    uint32_t session_id;
    FILE *urandom;

	printf ("%s - 802.11n packet injection \n");
	printf ("-----------------------------------------------------\n\n");

	
	if ( interface == NULL) {
		printf ("ERROR: Interface, or channel not set (see -h for more info)\n");
	
	}

    if ((urandom = fopen("/dev/urandom", "rb")) == NULL) {
        printf("ERROR:  Could not open urandom for session id: %s\n", strerror(errno));
      
    }

    fread(&session_id, 4, 1, urandom);
    fclose(urandom);

	printf("[+] Using interface %s\n",interface);

	if ((driver = lorcon_auto_driver(interface)) == NULL) {
		printf("[!] Could not determine the driver for %s\n", interface);
		
	} else {
		printf("[+]\t Driver: %s\n",driver->name);
	}

    if ((context = lorcon_create(interface, driver)) == NULL) {
        printf("[!]\t Failed to create context");
     
    }

	//Create Monitor Mode Interface
	if (lorcon_open_injmon(context) < 0) {
		printf("[!]\t Could not create Monitor Mode interface!\n");
		
	} else {
		printf("[+]\t Monitor Mode VAP: %s\n",lorcon_get_vap(context));
		lorcon_free_driver_list(driver);
	}

    //Get the MAC of the radio
    if (lorcon_get_hwmac(context, &smac) <= 0) {
        printf("[!]\t Could not get hw mac address\n");
       
    }

	// Set the channel we'll be injecting on
	//lorcon_set_complex_channel(context, &channel);


    for (mcs_iter = 8; mcs_iter <= 8; ) {
        printf("\n[.]\tMCS %u %s %s\n",
                mcs_iter, ht_iter ? "40mhz" : "20mhz",
                gi_iter ? "short-gi" : "");

        for (count = 0; count < npackets; count++) {
            memset(payload, 0, PAYLOAD_LEN);//allocate memory space for payload, filled with 0, buffer length payload_len
            memset(encoded_payload, 0, 14);

            // Set MCS count
            encoded_payload[0] = mcs_iter;


            // set the location code
            encoded_payload[1] = lcode & 0xFF;

            *encoded_counter = htonl(count);
            *encoded_max = htonl(npackets);
            *encoded_session = htonl(session_id);

            /*snprintf((char *) payload, PAYLOAD_LEN, "MCS %u %s%s Packet %u of %u KAPPA %u Name %s Session %u",
                    mcs_iter,
                    ht_iter ? "40MHz" : "20MHz",
                    gi_iter ? " short-gi": "",
                    count,
                    npackets,
                    lcode,
                    lname == NULL ? "n/a" : lname,
                    session_id);*/

            char payload[117] = {
            0x84, 0x20, 0x00, 0x00, 0x58, 0xcc, 0x52, 0xb5, 0xd9, 0xf0, // dur ffff
            0x70, 0x10, 0x5c, 0xf4, 0x07, 0x3b, 0x70, 0x10,
            0x5c, 0xf4, 0x07, 0x3b, 0xf0, 0xed, 0x22, 0xb0, // 0x0000 - seq no.
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, // BSS timestamp
            0x64, 0x00, 0x11, 0x00, 0x00, 0x0f, 0x73, 0x6f,
            0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67, 0x63,
            0x6c, 0x65, 0x76, 0x65, 0x72, 0x01, 0x08, 0x82,
            0x84, 0x8b, 0x96, 0x24, 0x30, 0x48, 0x6c, 0x03,
            0x01, 0x01, 0x05, 0x04, 0x00, 0x01, 0x00, 0x00,
            0x2a, 0x01, 0x05, 0x2f, 0x01, 0x05, 0x32, 0x04,
            0x0c, 0x12, 0x18, 0x60, 0xdd, 0x05, 0x00, 0x10,
            0x18, 0x01, 0x01, 0xdd, 0x16, 0x00, 0x50, 0xf2,
            0x01, 0x01, 0x00, 0x00, 0x50, 0xf2, 0x02, 0x01,
            0x00, 0x00, 0x50, 0xf2, 0x02, 0x01, 0x00, 0x00,
            0x50, 0xf2, 0x02};
            

            metapack = lcpa_init();

            timestamp = 1000;
            //adjustable_frameformat {beacon_interval,capabilities,payload}

            lcpf_beacon(metapack, smac, bmac,
                    0x00, 0x00, 0x00, 0x00,
                    timestamp, beacon_interval, capabilities);//only beacon_interval will impact the payload
            //lcpf_add_ie(metapack, 0, 3, "MCS_TEST");

            //lcpf_add_ie(metapack, 10, 14, encoded_payload);
            lcpa_append_copy(metapack,"IETAG",72, "\x84\x20\x00\x10\x84\x8b\x96\x24\x30\x48\x6c\x03\x01\x01\x05\x04\x00\x01\x00\x00\x2a\x01\x05\x2f\
\x01\x05\x32\x04\x0c\x12\x18\x60\xdd\x05\x00\x10\x84\x20\x00\x10\x84\x8b\x96\x24\x30\x48\x6c\x03\x01\x01\x05\x04\x00\x01\x00\x00\x2a\x01\
\x05\x2f\x01\x05\x32\x04\x0c\x12\x18\x60\xdd\x05\x00\x10");
            //lcpf_add_ie(metapack, 0, 3, "\x85\x20\x00");
            // Convert the LORCON metapack to a LORCON packet for sending
            txpack = (lorcon_packet_t *) lorcon_packet_from_lcpa(context, metapack);


            lorcon_packet_set_mcs(txpack, 1, mcs_iter, gi_iter, ht_iter);// configure the packet, including mcs, gi =setting guard band, ht_iter->setting the bandwidth)

          
            usleep(interval * 1000);

            //printf("\033[K\r");
            printf("[+] Sent %d frames\n", totalcount);
            //fflush(stdout);
            totalcount++;

            lcpa_free(metapack);
        }

        // reset them and increment the mcs
        gi_iter = 0; //setting guard band
        ht_iter = 1; //setting HT40 MODE, 1= HT40, 0 = HT20
        mcs_iter++;
    }
    // Close the interface
	lorcon_close(context);
    // Free the LORCON Context
	lorcon_free(context);

	
}

/*
int main(int argc, char *argv[]) {
	char *interface = NULL, *lname = NULL;
    unsigned int lcode = 0;
    unsigned int npackets = 10000;

	int c;
    lorcon_channel_t channel;
    const char *channel_str;

	lorcon_driver_t *drvlist, *driver;
	lorcon_t *context;

	lcpa_metapack_t *metapack;
	lorcon_packet_t *txpack;

    /* delay interval 
    unsigned int interval = 2;
*/
    /* Iterations through HT and GI 
    int mcs_iter = 0;
    int ht_iter = 1;
    int gi_iter = 0;
    unsigned int mcs_num = 0;
	unsigned int count = 0;

    unsigned int totalcount = 1;

    uint8_t *smac;

    uint8_t *bmac = "\x00\xDE\xAD\xBE\xEF\x00";

    uint8_t encoded_payload[14];
    uint32_t *encoded_counter = (uint32_t *) (encoded_payload + 2);
    uint32_t *encoded_max = (uint32_t *) (encoded_payload + 6);
    uint32_t *encoded_session = (uint32_t *) (encoded_payload + 10);

    uint8_t payload[PAYLOAD_LEN];

	// Timestamp
    struct timeval time;
    uint64_t timestamp;

	// Beacon Interval
	int beacon_interval = 1;

	// Capabilities
	int capabilities = 0x6422;

    // Session ID
    uint32_t session_id;
    FILE *urandom;

	printf ("%s - 802.11n packet injection \n", argv[0]);
	printf ("-----------------------------------------------------\n\n");

	while ((c = getopt(argc, argv, "hi:c:l:L:n:d:")) != EOF) {
		switch (c) {
			case 'i':
				interface = strdup(optarg);
				break;
	        case 'L':
                lname = strdup(optarg);
                break;

            case 'n':
                if (sscanf(optarg, "%u", &npackets) != 1) {
                    printf("ERROR: Unable to parse number of packets\n");
                    return -1;
                }
                break;

            case 'h':
				usage(argv);
                return -1;
				break;
            //case 'd':
              //mcs_num = sscanf(optarg,"%u",&);
              // printf('mcs_num= %d',mcs_num);
            //    break;
			default:
				usage(argv);
                return -1;
				break;
			}
	}

	if ( interface == NULL) {
		printf ("ERROR: Interface, or channel not set (see -h for more info)\n");
		return -1;
	}

    if ((urandom = fopen("/dev/urandom", "rb")) == NULL) {
        printf("ERROR:  Could not open urandom for session id: %s\n", strerror(errno));
        return -1;
    }

    fread(&session_id, 4, 1, urandom);
    fclose(urandom);

	printf("[+] Using interface %s\n",interface);

	if ((driver = lorcon_auto_driver(interface)) == NULL) {
		printf("[!] Could not determine the driver for %s\n", interface);
		return -1;
	} else {
		printf("[+]\t Driver: %s\n",driver->name);
	}

    if ((context = lorcon_create(interface, driver)) == NULL) {
        printf("[!]\t Failed to create context");
        return -1;
    }

	// Create Monitor Mode Interface
	if (lorcon_open_injmon(context) < 0) {
		printf("[!]\t Could not create Monitor Mode interface!\n");
		return -1;
	} else {
		printf("[+]\t Monitor Mode VAP: %s\n",lorcon_get_vap(context));
		lorcon_free_driver_list(driver);
	}

    // Get the MAC of the radio
    if (lorcon_get_hwmac(context, &smac) <= 0) {
        printf("[!]\t Could not get hw mac address\n");
        return -1;
    }

	// Set the channel we'll be injecting on
	//lorcon_set_complex_channel(context, &channel);


    for (mcs_iter = 8; mcs_iter <= 8; ) {
        printf("\n[.]\tMCS %u %s %s\n",
                mcs_iter, ht_iter ? "40mhz" : "20mhz",
                gi_iter ? "short-gi" : "");

        for (count = 0; count < npackets; count++) {
            memset(payload, 0, PAYLOAD_LEN);//allocate memory space for payload, filled with 0, buffer length payload_len
            memset(encoded_payload, 0, 14);

            // Set MCS count
            encoded_payload[0] = mcs_iter;


            // set the location code
            encoded_payload[1] = lcode & 0xFF;

            *encoded_counter = htonl(count);
            *encoded_max = htonl(npackets);
            *encoded_session = htonl(session_id);

            /*snprintf((char *) payload, PAYLOAD_LEN, "MCS %u %s%s Packet %u of %u KAPPA %u Name %s Session %u",
                    mcs_iter,
                    ht_iter ? "40MHz" : "20MHz",
                    gi_iter ? " short-gi": "",
                    count,
                    npackets,
                    lcode,
                    lname == NULL ? "n/a" : lname,
                    session_id);

            char payload[117] = {
            0x84, 0x20, 0x00, 0x00, 0x58, 0xcc, 0x52, 0xb5, 0xd9, 0xf0, // dur ffff
            0x70, 0x10, 0x5c, 0xf4, 0x07, 0x3b, 0x70, 0x10,
            0x5c, 0xf4, 0x07, 0x3b, 0xf0, 0xed, 0x22, 0xb0, // 0x0000 - seq no.
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, // BSS timestamp
            0x64, 0x00, 0x11, 0x00, 0x00, 0x0f, 0x73, 0x6f,
            0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67, 0x63,
            0x6c, 0x65, 0x76, 0x65, 0x72, 0x01, 0x08, 0x82,
            0x84, 0x8b, 0x96, 0x24, 0x30, 0x48, 0x6c, 0x03,
            0x01, 0x01, 0x05, 0x04, 0x00, 0x01, 0x00, 0x00,
            0x2a, 0x01, 0x05, 0x2f, 0x01, 0x05, 0x32, 0x04,
            0x0c, 0x12, 0x18, 0x60, 0xdd, 0x05, 0x00, 0x10,
            0x18, 0x01, 0x01, 0xdd, 0x16, 0x00, 0x50, 0xf2,
            0x01, 0x01, 0x00, 0x00, 0x50, 0xf2, 0x02, 0x01,
            0x00, 0x00, 0x50, 0xf2, 0x02, 0x01, 0x00, 0x00,
            0x50, 0xf2, 0x02};
            

            metapack = lcpa_init();

            timestamp = 1000;
            //adjustable_frameformat {beacon_interval,capabilities,payload}

            lcpf_beacon(metapack, smac, bmac,
                    0x00, 0x00, 0x00, 0x00,
                    timestamp, beacon_interval, capabilities);//only beacon_interval will impact the payload
            //lcpf_add_ie(metapack, 0, 3, "MCS_TEST");

            //lcpf_add_ie(metapack, 10, 14, encoded_payload);
            lcpa_append_copy(metapack,"IETAG",72, "\x84\x20\x00\x10\x84\x8b\x96\x24\x30\x48\x6c\x03\x01\x01\x05\x04\x00\x01\x00\x00\x2a\x01\x05\x2f\
\x01\x05\x32\x04\x0c\x12\x18\x60\xdd\x05\x00\x10\x84\x20\x00\x10\x84\x8b\x96\x24\x30\x48\x6c\x03\x01\x01\x05\x04\x00\x01\x00\x00\x2a\x01\
\x05\x2f\x01\x05\x32\x04\x0c\x12\x18\x60\xdd\x05\x00\x10");
            //lcpf_add_ie(metapack, 0, 3, "\x85\x20\x00");
            // Convert the LORCON metapack to a LORCON packet for sending
            txpack = (lorcon_packet_t *) lorcon_packet_from_lcpa(context, metapack);


            lorcon_packet_set_mcs(txpack, 1, mcs_iter, gi_iter, ht_iter);// configure the packet, including mcs, gi =setting guard band, ht_iter->setting the bandwidth)

            if (lorcon_inject(context,txpack) < 0 )
                return -1;

            usleep(interval * 1000);

            printf("\033[K\r");
            printf("[+] Sent %d frames", totalcount);
            fflush(stdout);
            totalcount++;

            lcpa_free(metapack);
        }

        // reset them and increment the mcs
        gi_iter = 0; //setting guard band
        ht_iter = 1; //setting HT40 MODE, 1= HT40, 0 = HT20
        mcs_iter++;
    }
    // Close the interface
	lorcon_close(context);
    // Free the LORCON Context
	lorcon_free(context);

	return 0;
}
*/

