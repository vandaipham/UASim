OMNET++: v5.5.1
inet: inet-4.2.0-cb6c37b3dc

--- Edit UdpSink.h,
protected:
    enum SelfMsgKinds { START = 1, STOP };

    UdpSocket socket;
    int localPort = -1;
    L3Address multicastGroup;
    simtime_t startTime;
    simtime_t stopTime;
    cMessage *selfMsg = nullptr;
    int numReceived = 0;
    simsignal_t arrivalSignal;
    simsignal_t posXSignal;
    simsignal_t posYSignal;
    simsignal_t posZSignal;
    
--- Add to UdpSink.cc
#include "inet/common/ModuleAccess.h"
#include "inet/mobility/contract/IMobility.h"

void UdpSink::initialize(int stage)
{
    ApplicationBase::initialize(stage);

    if (stage == INITSTAGE_LOCAL) {
        numReceived = 0;
        WATCH(numReceived);

        localPort = par("localPort");
        startTime = par("startTime");
        stopTime = par("stopTime");
        if (stopTime >= SIMTIME_ZERO && stopTime < startTime)
            throw cRuntimeError("Invalid startTime/stopTime parameters");
        selfMsg = new cMessage("UDPSinkTimer");

        arrivalSignal = registerSignal("arrival");
        posXSignal = registerSignal("posX");
        posYSignal = registerSignal("posY");
        posZSignal = registerSignal("posZ");
    }
}

void UdpSink::socketDataArrived(UdpSocket *socket, Packet *packet)
{
    if (packet->findTag<SignalPowerInd>() != nullptr) {
        auto signalPowerInd = packet->getTag<SignalPowerInd>();
        auto rxPower = signalPowerInd->getPower().get();
        EV_INFO << "RX power= " << rxPower << " W" << endl;

        emit(arrivalSignal, 10 * log10(rxPower) + 30);
        EV_INFO << "RSSI = " << 10 * log10(rxPower) + 30 << " dBm" << endl;

        cModule *host = getContainingNode(this);
        IMobility *mod = check_and_cast<IMobility *>(host->getSubmodule("mobility"));
        Coord pos = mod->getCurrentPosition();
        double posX = pos.x;
        double posY = pos.y;
        double posZ = pos.z;
        EV_INFO << "Current Position: X = " << posX << ", Y = " << posY << ", Z = " << posZ << endl;

        emit(posXSignal, posX);
        emit(posYSignal, posY);
        emit(posZSignal, posZ);
    }

    // process incoming packet
    processPacket(packet);
}

--- Add to pararameters UdpSink.ned 
@signal[arrival](type="long");
        @statistic[rxPower](title="rxPower"; source="arrival"; record=vector,stats; interpolationmode=none);
        
        @signal[posX](type="long");
        @statistic[posX](title="posX"; source="posX"; record=vector,stats; interpolationmode=none);
        
        @signal[posY](type="long");
        @statistic[posY](title="posY"; source="posY"; record=vector,stats; interpolationmode=none);
        
        @signal[posZ](type="long");
        @statistic[posZ](title="posZ"; source="posZ"; record=vector,stats; interpolationmode=none);


--- Add to UdpBasicApp.cc
#include "inet/mobility/contract/IMobility.h"

void UdpBasicApp::finish()
{
    cModule *host = getContainingNode(this);
    IMobility *mod = check_and_cast<IMobility *>(host->getSubmodule("mobility"));
    Coord pos = mod->getCurrentPosition();
    double posX = pos.x;
    double posY = pos.y;
    double posZ = pos.z;
    EV_INFO << "Current Position: X = " << posX << ", Y = " << posY << ", Z = " << posZ << endl;
    recordScalar("posX", posX);
    recordScalar("posY", posY);
    recordScalar("posZ", posZ);

    recordScalar("packets sent", numSent);
    recordScalar("packets received", numReceived);
    ApplicationBase::finish();
}


--- To save results to csv.
scavetool x *.sca *.vec -o demo.csv

