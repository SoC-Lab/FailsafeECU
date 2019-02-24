#include "packet.h"

uint8_t build_control_packet(uint8_t dest_address, uint8_t source_address, uint8_t command)
{
    return  ((CONTROL_ID     & 0x03) << PACKET_ID_BIT_POS) |
            ((dest_address   & 0x03) << CONTROL_DEST_ADDR_BIT_POS) |
            ((source_address & 0x03) << CONTROL_SOURCE_ADDR_BIT_POS) |
            ((command        & 0x03) << COMMAND_BIT_POS);
}

uint8_t build_data_packet(uint8_t dest_address, uint8_t data)
{
    return  ((dest_address & 0x03) << DATA_DEST_ADDR_BIT_POS) |
            ((data         & 0x3F) << DATA_BIT_POS);
}

uint8_t validate_data_packet(uint8_t source_address, uint8_t data_packet)
{
    if((data_packet & DATA_DEST_ADDR_MASK) == ((source_address & 0x03) << PACKET_ID_BIT_POS)) return 1;
    else                                                                                 return 0;
}

uint8_t validate_control_packet(uint8_t dest_address, uint8_t source_address, uint8_t command, uint8_t control_packet)
{
    if((control_packet & PACKET_ID_MASK)   == (CONTROL_ID << PACKET_ID_BIT_POS) &&
       (control_packet & CONTROL_DEST_ADDR_MASK)   == ((dest_address & 0x03) << CONTROL_DEST_ADDR_BIT_POS) &&
       (control_packet & CONTROL_SOURCE_ADDR_MASK) == ((source_address & 0x03) << CONTROL_SOURCE_ADDR_BIT_POS) &&
       (control_packet & COMMAND_MASK)     == ((command & 0x03) << COMMAND_BIT_POS)) return 1;
    else                                                                             return 0;
}
