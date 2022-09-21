DataCodes = {
	SCAN = "1", --tells slave to do scan, but not return data (used for multiple passes)
	DATA = "2", --tells master all data from scan has returned
	FULL_SCAN = "3", --tells master a scan has reached the /who limit of 50 results
	SCAN_AND_RETURN = "4", --tells slave to scan and return data
	IDLE = "5", --tells master slave is idle
	CONNECT = "6", --initiates connection between clients
	DISCONNECT = "7", --tells master/slave that one or the other has disconnected
	INCOMPLETE_DATA = "8", --tells master theres still more /who data being sent by slave
}