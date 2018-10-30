#ifndef __PACKET_H
#define __PACKET_H

#define TIMEOUT_S ((double) 0.1)

#define PACKET_ID_BIT_POS   ((uint8_t) 6)
#define DEST_ADDR_BIT_POS   ((uint8_t) 4)
#define SOURCE_ADDR_BIT_POS ((uint8_t) 2)
#define COMMAND_BIT_POS     ((uint8_t) 0)
#define DATA_BIT_POS        ((uint8_t) 0)

#define PACKET_ID_MASK   ((uint8_t) (0x03 << PACKET_ID_BIT_POS))
#define COMMAND_MASK     ((uint8_t) (0x03 << COMMAND_BIT_POS))
#define DEST_ADDR_MASK   ((uint8_t) (0x03 << CONTROL_DEST_ADDR_BIT_POS))
#define SOURCE_ADDR_MASK ((uint8_t) (0x03 << CONTROL_SOURCE_ADDR_BIT_POS))
#define DATA_MASK        ((uint8_t) (0x3F << DATA_BIT_POS))

#define CONTROL_ID ((uint8_t) 0x00)
#define THS_ID     ((uint8_t) 0x01)
#define MCU_ID     ((uint8_t) 0x02)
#define ECU_ID     ((uint8_t) 0x03)

#define REQUEST     ((uint8_t) 0x00 << 0)
#define ACKNOWLEDGE ((uint8_t) 0x03 << 0)
#define ERROR_1     ((uint8_t) 0x01 << 0)
#define ERROR_2     ((uint8_t) 0x02 << 0)

uint8_t build_control_packet(uint8_t dest_address, uint8_t source_address, uint8_t command);
uint8_t build_data_packet(uint8_t dest_address, uint8_t data);
uint8_t validate_data_packet(uint8_t dest_address, uint8_t data_packet);
uint8_t validate_control_packet(uint8_t dest_address, uint8_t source_address, uint8_t command, uint8_t control_packet)

#endif // __PACKET_H