package app.beautyminder.repository;

import app.beautyminder.domain.User;
import org.jetbrains.annotations.NotNull;
import org.springframework.data.mongodb.repository.Aggregation;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends MongoRepository<User, String> {

    Optional<User> findByEmail(String email);

    Optional<User> findByPhoneNumber(String phoneNumber);

    Optional<User> findByNickname(String nickname);

    List<User> findByProfileImageIsNotNull();

    List<User> findByCreatedAtAfter(LocalDateTime date);

    List<User> findByBaumann(String baumannSkinType);

    @Aggregation(pipeline = {
            "{ $match: { 'baumannSkinType': ?0 } }",
            "{ $sample: { size: 10 } }"
    })
    List<User> findRandomByBaumann(String baumannSkinType);

    @Query("{'$or': [{'email': ?0}, {'nickname': ?1}]}")
    Optional<User> findByEmailOrNickname(String email, String nickname);

    Optional<User> findByEmailAndPassword(String email, String password);

    @Query("{'authorities': ?0}")
    List<User> findByAuthority(String authority);

    void deleteUserByEmail(String email);

    void deleteById(@NotNull String userId);

}
