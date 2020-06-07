//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.visualizer.integrated.IntegratedVisualizer;


network UAVnetwork
{
    parameters:
        int numHosts;
        @display("bgb=800,600");
    submodules:
        host[numHosts]: <default("WirelessHost")> like INetworkNode {
            @display("i=misc/aircraft");
        }

        phone: <default("WirelessHost")> like INetworkNode {
            @display("i=misc/person");
        }

        configurator: Ipv4NetworkConfigurator {
            @display("p=900,350");
        }

        radioMedium: <default("UnitDiskRadioMedium")> like IRadioMedium {
            @display("p=900,580");
        }

        visualizer: IntegratedVisualizer {
            @display("p=900,100");
        }
}
