awe_monitor
===========

Support for a pool of production awe clients

For support launching awe clients on remote machines, proper configuration of ssh keys is required. The native launch method uses ssh to launch a remote client. It assumes there is a script it can envoke on the remote machine. This script is specified in the deploy.cfg.

SSH Keys - A public ssh key needs to be added to the authorized_keys file of the user that the awe-client will run as. This needs to be done on all awe-client hosts listed in the deploy.cfg file (client-addrs).

Remote Script - A remote script is needed that can be envoked by the monitor. The script should take care of setting up the environment and launching an awe-client. The name of the remote script is specified in the deploy.cfg file (remote-script).
