# encoding: utf-8
# author: Nolan Davidson
# author: Christoph Hartmann

require 'helper'

describe 'Inspec::Resources::MssqlSession' do
  it 'verify mssql_session configuration' do
    resource = load_resource('mssql_session', user: 'sa', password: 'yourStrong(!)Password', host: 'localhost')
    _(resource.user).must_equal 'sa'
    _(resource.password).must_equal 'yourStrong(!)Password'
    _(resource.host).must_equal 'localhost'
  end

  it 'verify mssql_session configuration with custom sqlserver port and user in domain' do
    resource = load_resource('mssql_session', user: 'DOMAIN\sa', password: 'yourStrong(!)Password', host: 'localhost,1533')
    _(resource.user).must_equal 'DOMAIN\sa'
    _(resource.password).must_equal 'yourStrong(!)Password'
    _(resource.host).must_equal 'localhost,1533'
  end

  it 'run a SQL query' do
    resource = load_resource('mssql_session', user: 'sa', password: 'yourStrong(!)Password', host: 'localhost')
    query = resource.query("SELECT SERVERPROPERTY('ProductVersion') as result")
    _(query.size).must_equal 1
    _(query.row(0).column('result').value).must_equal '14.0.600.250'
  end

  it 'runs sqlcmd with integrated security' do
    resource = load_resource('mssql_session', integrated_security: true)
    command = resource.sql_cmd("SELECT SERVERPROPERTY('ProductVersion') as result")
    command.must_match(/-E/)
  end

  it 'runs sqlcmd with user and password' do
    user = 'sa'
    password = 'myPass'
    resource = load_resource('mssql_session', user: user, password: password)
    command = resource.sql_cmd("SELECT SERVERPROPERTY('ProductVersion') as result")
    command.must_match(/-U '#{user}' -P '#{password}'/)
  end

  it 'runs sqlcmd with integrated security when integrated security is true, user and password are given' do
    user = 'sa'
    password = 'yourStrong(!)Password'
    resource = load_resource('mssql_session', integrated_security: true, user: user, password: password)
    command = resource.sql_cmd("SELECT SERVERPROPERTY('ProductVersion') as result")
    command.must_match(/-E/)
    command.wont_match(/-U/)
    command.wont_match(/-P/)
  end
  
end
