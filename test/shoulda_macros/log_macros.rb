module LogMacros
  def should_contain_one_log_record
    should "contain a log record" do
      assert_equal 1, @con[@mongo_logger.mongo_collection_name].count
    end
  end
end
