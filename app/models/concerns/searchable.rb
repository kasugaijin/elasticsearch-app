module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :artist, type: :text
      indexes :title, type: :text
      indexes :lyrics, type: :text
      indexes :genre, type: :keyword
    end

    # basic query
    def self.search(query)
      self.__elasticsearch__.search(query)
    end

    def self.search_artist_field(query)
      params = {
        query: {
          match: {
            artist: query,
          },
        },
      }

      self.__elasticsearch__.search(params)
    end

    def self.search_multiple_fields(query)
      params = {
        query: {
          multi_match: {
            query: query, 
            fields: [ :title, :artist, :lyrics ] 
          },
        },
      }
    
      self.__elasticsearch__.search(params)
    end

    def self.search_and_filter_by_genre(query, genre = nil)
      params = {
        query: {
          bool: {
            must: [
              {
                multi_match: {
                  query: query, 
                  fields: [ :title, :artist, :lyrics ] 
                }
              },
            ],
            filter: [
              {
                term: { genre: genre }
              }
            ]
          }
        }
      }
  
      self.__elasticsearch__.search(params)
    end

    # boosts the relevance score for artists matching query
    def self.search_and_boost_artist(query)
      params = {
        query: {
          bool: {
            should: [
              { match: { title: query }},
              { match: { artist: { query: query, boost: 5 } }},
              { match: { lyrics: query }},
            ],
          }
        },
      }
  
      self.__elasticsearch__.search(params)
    end

  end
end