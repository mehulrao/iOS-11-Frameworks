#!/usr/bin/env python
# encoding: utf-8

from CoreAutomation		import *
from MCTestUtils		import *
import objc
objc.loadBundle("CoreUtils", globals(), bundle_path=objc.pathForFramework(u'/System/Library/PrivateFrameworks/CoreUtils.framework'))

class MCDashboardClient:
	
	KeyCategory							= "_cat"
	KeyOpcode							= "_op"
	
	# Multipeer Connectivity Category
	CategoryMultipeerConnectivity		= "MC"
	
	# Opcodes
	OpcodeLatencyData					= "CALatencyData"
	
	def __init__(self):
		self.client = CUDashboardClient.alloc().init()
	
	def activate(self):
		self.client.activate()
	
	def invalidate(self):
		self.client.invalidate()
	
	def log(self, dictionary):
		self.client.logJSON_(dictionary)

	def logLatencyData(self, sessionID, localDevice, remoteDevice, interface, data):
		
		buildLPeer		= str(localDevice.build())
		modelLPeer		= str(localDevice.hardwareModel())
		localPeer		= PeerIDForDevice(localDevice)
		remotePeer		= PeerIDForDevice(remoteDevice)
		
		# Dashboard is currently UDP so we need to be careful not to go over MTU. We'll restrict the number
		# of latency measurements to 30 for now, to be conservative.
		
		maxPerChunk = 30
		listOfDataChunks = [data[i:i+maxPerChunk] for i in range(0, len(data), maxPerChunk)]
		
		for dataChunk in listOfDataChunks:

			dashboardDictionary = {
				MCDashboardClient.KeyCategory				: MCDashboardClient.CategoryMultipeerConnectivity,
				MCDashboardClient.KeyOpcode					: MCDashboardClient.OpcodeLatencyData,
				"sid"										: sessionID,
				"buildLPeer"								: buildLPeer,
				"modelLPeer"								: modelLPeer,
				"localPeer"									: localPeer,
				"remotePeer"								: remotePeer,
				"if"										: interface,
				"data"										: dataChunk
			}
		
			self.log(dashboardDictionary)

