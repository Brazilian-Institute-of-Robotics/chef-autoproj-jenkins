def public_key_of(secret_key)
    key = OpenSSL::PKey::RSA.new(secret_key)
    "#{key.ssh_type} #{[key.to_blob].pack('m0')} auto-generated key"
end
node.run_state[:jenkins_private_key] = data_bag_item('jenkins', 'auth')['admin_key']

