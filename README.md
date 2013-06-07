puppet-anthracite
=================

Send puppet changes summary to anthracite. Main purpose is to just record when system state changes, and specify which resources changed, as opposed to a full blown report processor or only reporting failed runs. In the below config the timeout options are same as net/http timeout opts. 


Sample config (/etc/puppet/anthracite.yaml):  

    ---  
    :anthracite_host: localhost  
    :anthracite_port: 8081  
    :anthracite_open_timeout: 5  
    :anthracite_write_timeout: 5  
