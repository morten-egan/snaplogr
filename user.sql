create user snaplogr identified by snaplogr
default tablespace users
temporary tablespace temp
quota unlimited on users;

grant connect, create table, create procedure, create sequence, create type to snaplogr;
grant execute on dbms_obfuscation_toolkit to snaplogr;