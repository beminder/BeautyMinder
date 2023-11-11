package app.beautyminder.service;

import app.beautyminder.domain.CosmeticExpiry;
import app.beautyminder.domain.Todo;
import app.beautyminder.domain.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Slf4j
@RequiredArgsConstructor
@Service
public class MongoService {

    private final Map<Class<?>, Set<String>> bannedFieldsPerClass = new HashMap<>();
    /*
    MongoRepository:
        Provides CRUD operations and simple query derivation.
        Easier to use for common scenarios.
        Spring Data generates the implementation based on method names or annotations.

    MongoTemplate:
        More powerful, offering a wide range of MongoDB operations.
        Provides fine-grained control over queries and updates.
        Useful for complex queries, operations, or aggregations not covered by repository abstraction.
    */
    @Autowired
    private MongoTemplate mongoTemplate;

    public MongoService(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
        // Initialize the map with banned fields for each class
        bannedFieldsPerClass.put(Todo.class, Set.of("user"));
        bannedFieldsPerClass.put(User.class, Set.of("password", "email"));
        bannedFieldsPerClass.put(CosmeticExpiry.class, Set.of("id", "createdAt"));
    }

    public <T> Optional<T> updateFields(String id, Map<String, Object> updates, Class<T> entityClass) {
        var query = new Query(Criteria.where("id").is(id));
        var stringBuilder = new StringBuilder();

        var bannedFields = bannedFieldsPerClass.getOrDefault(entityClass, Set.of());

        if (mongoTemplate.exists(query, entityClass)) {
            var update = new Update();
            updates.entrySet().stream()
                    .filter(entry -> !bannedFields.contains(entry.getKey()))
                    .forEach(entry -> {
                        stringBuilder.append(entry.getKey()).append(",");
                        update.set(entry.getKey(), entry.getValue());
                    });

            mongoTemplate.updateFirst(query, update, entityClass);
            log.info("BEMINDER: {} has been updated: {}", entityClass.getSimpleName(), stringBuilder);
            return Optional.ofNullable(mongoTemplate.findOne(query, entityClass));
        } else {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, entityClass.getSimpleName() + " not found: " + id);
        }
    }
}