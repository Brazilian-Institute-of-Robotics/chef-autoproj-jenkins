module ChefAutoprojJenkins
    def self.public_key_of(secret_key)
        key = OpenSSL::PKey::RSA.new(secret_key)
        "#{key.ssh_type} #{[key.to_blob].pack('m0')} auto-generated key"
    end
end

