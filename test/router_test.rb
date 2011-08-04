# encoding: UTF-8

require 'vines'
require 'minitest/autorun'

class RouterTest < MiniTest::Unit::TestCase
  def setup
    @router = Vines::Router.new
  end

  def test_non_routable_stanza_is_local
    stanza = MiniTest::Mock.new
    stanza.expect(:name, 'auth')
    assert @router.local?(stanza)
    assert stanza.verify
  end

  def test_stanza_missing_to_is_local
    stanza = MiniTest::Mock.new
    stanza.expect(:name, 'message')
    stanza.expect(:[], nil, ['to'])
    assert @router.local?(stanza)
    assert stanza.verify
  end

  def test_stanza_with_local_jid_is_local
    config = MiniTest::Mock.new
    config.expect(:local_jid?, true, ['alice@wonderland.lit'])
    stream = MiniTest::Mock.new
    stream.expect(:config, config)
    stream.expect(:stream_type, :client)
    @router << stream

    stanza = MiniTest::Mock.new
    stanza.expect(:name, 'message')
    stanza.expect(:[], 'alice@wonderland.lit', ['to'])
    assert @router.local?(stanza)

    assert stanza.verify
    assert stream.verify
    assert config.verify
  end

  def test_stanza_with_remote_jid_is_not_local
    config = MiniTest::Mock.new
    config.expect(:local_jid?, false, ['alice@wonderland.lit'])
    stream = MiniTest::Mock.new
    stream.expect(:config, config)
    stream.expect(:stream_type, :client)
    @router << stream

    stanza = MiniTest::Mock.new
    stanza.expect(:name, 'message')
    stanza.expect(:[], 'alice@wonderland.lit', ['to'])
    assert !@router.local?(stanza)

    assert stanza.verify
    assert stream.verify
    assert config.verify
  end
end
